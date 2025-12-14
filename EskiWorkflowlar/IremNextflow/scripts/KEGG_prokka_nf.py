#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import requests
import time
import glob
from Bio import SeqIO
from openpyxl import Workbook

# --- KEGG API DÖNÜŞTÜRÜCÜ (GÜNCELLENMİŞ) ---
def map_uniprot_to_kegg_direct(uniprot_ids, chunk_size=50):
    """
    UniProt ID'lerini KEGG'in kendi 'conv' API'sini kullanarak çevirir.
    Daha güvenilir ve hızlıdır.
    """
    mapping_dict = {}
    total = len(uniprot_ids)
    
    # Listeyi küçük parçalara böl (URL çok uzamasın diye 50'şerli)
    for i in range(0, total, chunk_size):
        chunk = uniprot_ids[i:i+chunk_size]
        if not chunk: continue
        
        # Format: up:P00561+up:P00547 ...
        query_ids = "+".join([f"uniprot:{uid}" for uid in chunk])
        url = f"http://rest.kegg.jp/conv/genes/{query_ids}"
        
        print(f"KEGG'e soruluyor ({i}/{total})...")
        
        try:
            r = requests.get(url)
            if r.status_code == 200 and r.text.strip():
                lines = r.text.strip().split('\n')
                for line in lines:
                    parts = line.split('\t')
                    if len(parts) >= 2:
                        # Gelen: up:P00561  eco:b0002
                        u_id = parts[0].replace("up:", "").replace("uniprot:", "")
                        k_id = parts[1] # eco:b0002
                        mapping_dict[u_id] = k_id
            time.sleep(0.5) # KEGG sunucusunu yormamak için bekleme
        except Exception as e:
            print(f"Hata olustu: {e}")
            
    print(f"Toplam {len(mapping_dict)} adet eslesme bulundu!")
    return mapping_dict

def get_pathways_for_kegg_ids(kegg_id_list, chunk_size=50):
    """
    KEGG ID'leri (eco:b0002 vb.) alıp pathway'lerini bulur.
    """
    pathway_map = {}
    total = len(kegg_id_list)
    
    for i in range(0, total, chunk_size):
        chunk = kegg_id_list[i:i+chunk_size]
        if not chunk: continue
        
        # Format: eco:b0002+eco:b0003
        query = "+".join(chunk)
        url = f"http://rest.kegg.jp/link/pathway/{query}"
        
        try:
            r = requests.get(url)
            if r.status_code == 200 and r.text.strip():
                for line in r.text.strip().split('\n'):
                    parts = line.split('\t')
                    if len(parts) >= 2:
                        gene_id = parts[0]
                        path_id = parts[1] # path:eco00260
                        
                        if gene_id not in pathway_map:
                            pathway_map[gene_id] = []
                        pathway_map[gene_id].append(path_id)
            time.sleep(0.5)
        except:
            pass
            
    return pathway_map

def find_gbf_file(prokka_dir):
    files = glob.glob(os.path.join(prokka_dir, "*.gbf")) + glob.glob(os.path.join(prokka_dir, "*.gbk"))
    if not files: raise FileNotFoundError("GBF/GBK dosyasi bulunamadi!")
    return files[0]

def analyze(prokka_dir):
    gbf = find_gbf_file(prokka_dir)
    print(f"Analiz ediliyor: {gbf}")
    
    cds_list = []
    # Genbank dosyasını oku
    for rec in SeqIO.parse(gbf, "genbank"):
        for feat in rec.features:
            if feat.type == "CDS":
                inf = feat.qualifiers.get("inference", [])
                # UniProt ID'sini çek
                uid = next((x.split(":")[-1] for x in inf if "UniProtKB" in x), None)
                
                cds_list.append({
                    "gene": feat.qualifiers.get("gene", [""])[0],
                    "inference": uid, # UniProt ID burada
                    "product": feat.qualifiers.get("product", [""])[0],
                    "kegg_id": "N/A",
                    "pathways": "N/A"
                })
    
    # Sadece UniProt ID'si olanları filtrele
    valid_uids = list(set([x["inference"] for x in cds_list if x["inference"]]))
    print(f"Toplam {len(valid_uids)} UniProt ID bulundu. KEGG donusumu basliyor...")

    # 1. ADIM: UniProt -> KEGG ID
    kegg_mapper = map_uniprot_to_kegg_direct(valid_uids)
    
    # 2. ADIM: KEGG ID -> Pathways
    # Bulunan tüm KEGG ID'lerini topla
    found_kegg_ids = list(set(kegg_mapper.values()))
    print(f"Pathway verileri cekiliyor ({len(found_kegg_ids)} gen icin)...")
    pathway_mapper = get_pathways_for_kegg_ids(found_kegg_ids)

    # 3. ADIM: Verileri Birleştir ve Excel'e Yaz
    wb = Workbook()
    ws = wb.active
    ws.append(["Gene", "UniProt", "Product", "KEGG ID", "Pathways"])
    
    match_count = 0
    for item in cds_list:
        uid = item["inference"]
        
        # KEGG ID var mı?
        if uid and uid in kegg_mapper:
            kid = kegg_mapper[uid]
            item["kegg_id"] = kid
            match_count += 1
            
            # Pathway var mı?
            if kid in pathway_mapper:
                # 'path:eco00260' -> 'eco00260' temizliği yapabiliriz istersen
                item["pathways"] = ", ".join(pathway_mapper[kid])
        
        ws.append([
            item["gene"], 
            item["inference"], 
            item["product"], 
            item["kegg_id"], 
            item["pathways"]
        ])
    
    wb.save("final_report.xlsx")
    print(f"Excel kaydedildi: final_report.xlsx")
    print(f"ÖZET: {len(cds_list)} genden {match_count} tanesine KEGG ID bulundu.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Klasor yolu gerekli!")
        sys.exit(1)
    analyze(sys.argv[1])
