process BCFTOOLS_CONCENSUS {
    container 'quay.io/biocontainers/bcftools:1.9--ha228f0b_4'
    input:
    tuple path(zipped_file), path(indexed_vcf), path(vcf_file)
    path ref_file

    output:
    path concensus_file

    script:
    clean_name = zipped_file.getName()
                            .replace('_sorted', '')
                            .replace('.vcf.gz', '')

    concensus_file = "${clean_name}.fasta"

    "bcftools consensus -f $ref_file $zipped_file > $concensus_file"
}