process SAMTOOLS_INDEX {
    // Indexes the sorted bam file and then returns the path to indexed path
    input:
    path sorted_bam

    output:
    path index_bam

    script:
    index_bam = "${sorted_bam.baseName}.bam.bai"
    "samtools index $sorted_bam"
}