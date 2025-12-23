process BCFTOOLS_INDEX {
    container 'quay.io/biocontainers/bcftools:1.9--ha228f0b_4'
    input:
    path bcf_file

    output:
    tuple path(zipped_file), path(indexed_vcf), path(vcf_file)

    script:
    vcf_file = "${bcf_file.baseName}.vcf"
    indexed_vcf = "${bcf_file.baseName}.vcf.gz.csi"
    zipped_file = "${bcf_file.baseName}.vcf.gz"
    """
    bcftools convert -O v -o $vcf_file $bcf_file
    bcftools view -Oz -o $zipped_file $bcf_file
    bcftools index $zipped_file
    """
}