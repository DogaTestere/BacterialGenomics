process VISUALIZE_RESULTS {
    publishDir "results/Visualizations", mode: 'copy'

    input:
    path prokka_dir      // Prokka çıktısını girdi olarak alıyoruz
    path python_script   // Python kodunu alıyoruz

    output:
    path "*.png"         // Çıktı olarak resim dosyalarını veriyoruz

    script:
    """
    python3 ${python_script} ${prokka_dir}
    """
}
