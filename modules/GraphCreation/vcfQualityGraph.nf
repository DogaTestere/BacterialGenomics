process VCF_QUALITY_GRAPH {
    conda 'conda-forge::python=3.10 conda-forge::matplotlib=3.10.8 conda-forge::pandas=2.3.3'
    input:
    tuple path(zipped_file), path(indexed_vcf), path(vcf_file)
    path python_script

    output:
    path "*.png"
    path "*.tsv"

    script:
    results_tsv = "${vcf_file.baseName}.tsv" // Not sure if this will return .tsv.tsv or just .tsv
    graph_png = "${vcf_file.baseName}.png"
    """
    python3 ${python_script} \
        --vcf ${vcf_file} \
        --out ${results_tsv} \
        --plot ${graph_png}
    """
}