process RUN_KEGG_ANALYSIS {
    //publishDir "results/Annotation_Results", mode: 'copy'
    conda 'conda-forge::python=3.10 conda-forge::openpyxl=3.1.5 conda-forge::requests=2.32.5 anaconda::Bio=1.8.5'
    
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
