process VCF_QUALITY_GRAPH {
    input:
    tuple path(zipped_file), path(indexed_vcf), path(vcf_file)
    path python_script

    output:
    path "*_qual.png"
    path "*_depth.png"
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