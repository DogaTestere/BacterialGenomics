process FASTA_STATS {    // Kaç adet sequence (contig / kromozom) olduğu ,Toplam baz (bp) sayısı

    tag "$fasta.simpleName"        // log okunabilirliğini artırmak için kullanılır

    input:
        path fasta

    output:
        path "${fasta.simpleName}_fasta_stats.tsv", emit: stats   // birden fazla outputta,FASTA_STATS.out dosyası stat

    script:
    """
    if [[ "${fasta}" == *.gz ]]; then  # [[ kısmı koşul kısmı
        seq_count=\$(zcat ${fasta} | grep -c "^>")   # zcat .gz dosyayı açmadan (diske çıkarmadan) stdout’a “açılmış haliyle” yazar.Yani DRB1-3123.fa.gz içeriği “FASTA metni” olarak akmaya başlar.grep "^>" FASTA formatında başlık satırları > ile başlar.-c leri sayar: eşleşen satır sayısını verir.
        total_bp=\$(zcat ${fasta} | grep -v "^>" | wc -c)  # -v = tersine çevir (eşleşmeyenleri al) Yani > ile başlayan header satırlarını çıkargeriye sadece dizilim satırları (A/C/G/T/N...) kalır wc = word count aracı -c = byte/character say böylece sequence satırlarının toplam karakter sayısı alınır
    else
        seq_count=\$(grep -c "^>" ${fasta})
        total_bp=\$(grep -v "^>" ${fasta} | wc -c)
    fi   # if aşamasını bitirmek için kullanılır,bash de

    echo -e "sample\\tsequences\\ttotal_bp" > ${fasta.simpleName}_fasta_stats.tsv  # -e kaçış karakterlerini aktif eder (\t gibi)\t tab demektir → TSV kolon ayırıcı > tek ok: dosyayı sıfırdan oluşturur / üzerine yazar
    echo -e "${fasta.simpleName}\\t\${seq_count}\\t\${total_bp}" >> ${fasta.simpleName}_fasta_stats.tsv  # >> çift ok: dosyanın SONUNA ekler,echo print demektir
    """
}

