process SAMTOOLS_SORT {
    // Converts sam file into a bam file then sorts it, returns the sorted bam file
    input:
    path sam_file
    val thread_val

    output:
    path sorted_bam

    script:
    bam_file = "${sam_file.baseName}.bam"
    tmp_file = "${sam_file.baseName}.tmp.sort"
    sorted_bam = "${sam_file.baseName}_sorted.bam"
    """
    mkdir -p bam
    samtools view -uS -o bam/$bam_file $sam_file
    samtools sort -@ $thread_val -T $tmp_file -o $sorted_bam bam/$bam_file
    """
}