process SAMTOOLS_INDEX {
    container 'quay.io/biocontainers/samtools:1.9--h91753b0_8'
    input:
    path sorted_bam

    output:
    path index_bam

    script:
    index_bam = "${sorted_bam.baseName}.bam.bai"
    "samtools index $sorted_bam"
}