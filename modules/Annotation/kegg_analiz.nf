process RUN_KEGG_ANALYSIS {
    publishDir "results/Annotation_Results", mode: 'copy'
    
    input:
    path prokka_cikti_klasoru
    path python_kodu

    output:
    path "*.xlsx", emit: excel_cikisi

    script:
    """
    python3 ${python_kodu} ${prokka_cikti_klasoru}
    """
}
