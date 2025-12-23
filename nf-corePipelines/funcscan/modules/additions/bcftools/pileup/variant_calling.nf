process BCFTOOLS_CALL {
    container 'quay.io/biocontainers/bcftools:1.9--ha228f0b_4'
    input:
    path ref_file
    path sorted_bam
    path indexed_bam

    output:
    path bcf_file

    script:
    bcf_file = "${sorted_bam.baseName}.bcf"
    "bcftools mpileup -f $ref_file $sorted_bam | bcftools call -mv -Ob -o $bcf_file"
}