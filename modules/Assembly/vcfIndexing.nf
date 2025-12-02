process BCFTOOLS_INDEX {
    // Takes the bcf file and turns it into vcf before indexing and zipping it
    // Output is both zipped and the indexed file since concensus genome creation needs both
    input:
    path bcf_file

    output:
    tuple path(zipped_file), path(indexed_vcf)

    script:
    vcf_file = "${bcf_file.baseName}.vcf"
    indexed_vcf = "${bcf_file.baseName}.vcf.gz.tbi"
    zipped_file = "${bcf_file.baseName}.vcf.gz"
    """
    bcftools convert -O v -o $vcf_file $bcf_file
    bgzip -c $vcf_file > $zipped_file
    tabix -p vcf $zipped_file
    """
}