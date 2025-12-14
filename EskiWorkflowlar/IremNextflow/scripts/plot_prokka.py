#!/usr/bin/env python3
import sys
import os
import glob
import matplotlib.pyplot as plt
import seaborn as sns # Daha güzel renkler için

# Seaborn temasını aktif et
sns.set_theme(style="whitegrid")

def plot_stats(prokka_dir):
    txt_files = glob.glob(os.path.join(prokka_dir, "*.txt"))
    if not txt_files:
        print("Hata: .txt dosyasi bulunamadi!")
        return
    
    stat_file = txt_files[0]
    stats = {}
    with open(stat_file, 'r') as f:
        for line in f:
            parts = line.strip().split(':')
            if len(parts) == 2:
                key = parts[0].strip()
                try:
                    val = int(parts[1].strip())
                    stats[key] = val
                except ValueError:
                    pass

    # --- GRAFİK 1: Genom Özellikleri (Bar Chart - İyileştirilmiş) ---
    features = ['CDS', 'tRNA', 'rRNA', 'tmRNA', 'gene']
    counts = [stats.get(f, 0) for f in features]
    
    plt.figure(figsize=(10, 6))
    # Modern bir renk paleti kullan
    colors = sns.color_palette("husl", len(features))
    bars = plt.bar(features, counts, color=colors, edgecolor='black', alpha=0.7)
    
    plt.title('Genom Özellik Dağılımı', fontsize=18, fontweight='bold', pad=20)
    plt.xlabel('Özellik Tipi', fontsize=14, labelpad=15)
    plt.ylabel('Sayı', fontsize=14, labelpad=15)
    plt.xticks(fontsize=12)
    plt.yticks(fontsize=12)
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    
    for bar in bars:
        yval = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2, yval + (yval*0.01), int(yval), ha='center', va='bottom', fontsize=11, fontweight='bold')
        
    plt.tight_layout()
    plt.savefig('genom_ozellikleri.png', dpi=300, bbox_inches='tight')
    print("Grafik 1 (Bar) olusturuldu.")

    # --- GRAFİK 2: Fonksiyon Dağılımı (Pie Chart - Profesyonel) ---
    tsv_files = glob.glob(os.path.join(prokka_dir, "*.tsv"))
    if tsv_files:
        hypothetical = 0
        functional = 0
        with open(tsv_files[0], 'r') as f:
            next(f) # Başlığı atla
            for line in f:
                if "hypothetical protein" in line:
                    hypothetical += 1
                else:
                    functional += 1
        
        labels = ['Hipotetik (Bilinmeyen)', 'Fonksiyonel (Bilinen)']
        sizes = [hypothetical, functional]
        # Pastel renkler kullan
        colors = sns.color_palette('pastel')[0:2]
        explode = (0.1, 0)  # Hipotetik kısmı dışarı çıkar

        fig, ax = plt.subplots(figsize=(9, 9))
        
        # Yüzdeleri dilimin içine, etiketleri dışarıya (lejanta) alıyoruz
        wedges, texts, autotexts = ax.pie(sizes, 
                                          explode=explode, 
                                          labels=None, # Etiketleri pasta üzerine yazma
                                          autopct='%1.1f%%', 
                                          shadow=True, 
                                          startangle=90, 
                                          colors=colors,
                                          pctdistance=0.7, # Yüzdenin merkeze uzaklığı
                                          textprops={'fontsize': 14, 'fontweight': 'bold', 'color': 'white'})

        # Yüzde yazılarının rengini koyu yap (okunabilirlik için)
        plt.setp(autotexts, size=14, weight="bold", color="black")
        
        # Başlık
        ax.set_title('Gen Fonksiyon Dağılımı', fontsize=18, fontweight='bold', pad=20)
        
        # Lejant (Açıklama Kutusu) Ekle
        ax.legend(wedges, labels,
                  title="Gen Kategorileri",
                  loc="center left",
                  bbox_to_anchor=(1, 0, 0.5, 1), # Kutuyu grafiğin sağına al
                  fontsize=12,
                  title_fontsize=14)

        plt.tight_layout()
        plt.savefig('fonksiyon_dagilimi.png', dpi=300, bbox_inches='tight')
        print("Grafik 2 (Pie) olusturuldu.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Kullanim: python scripts/plot_prokka.py <prokka_output_folder>")
    else:
        # Seaborn kütüphanesi yoksa kur (Tek seferlik)
        try:
            import seaborn
        except ImportError:
            print("Seaborn kütüphanesi kuruluyor...")
            os.system("pip install seaborn")
        
        plot_stats(sys.argv[1])
