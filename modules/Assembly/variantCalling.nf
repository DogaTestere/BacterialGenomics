process BCFTOOLS_CALL {
    input:
    path ref_file
    path index_bam

    output:
    path bcf_file

    script:
    bcf_file = "${index_bam.baseName}.bcf"
    "bcftools mpileup -f $ref_file $index_bam | bcftools call -mv -Ob -o $bcf_file"
}