process RUN_KEGG_ANALYSIS {
    //publishDir "results/Annotation_Results", mode: 'copy'
    conda 'conda-forge::python=3.10 conda-forge::openpyxl conda-forge::requests bioconda::Bio'
    
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
