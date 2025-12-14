process ANNOTATE_GENOME {
    // Sonuçları bu klasöre kopyala
    publishDir "results/annotation", mode: 'copy'

    input:
    path genome_fasta  // Gelen .fasta dosyası

    output:
    // Python kodumuz klasör istiyordu, o yüzden klasörü çıktı veriyoruz
    path "prokka_out", emit: annotation_dir

    script:
    """
    # Prokka'yı çalıştırıyoruz
    # --outdir: Çıktı klasörünün adı (prokka_out)
    # --prefix: Dosyaların adı (e_coli.gbf, e_coli.fna vs.)
    # --force: Eğer klasör varsa üzerine yaz
    
    prokka --outdir prokka_out --prefix e_coli --force ${genome_fasta}
    """
}
