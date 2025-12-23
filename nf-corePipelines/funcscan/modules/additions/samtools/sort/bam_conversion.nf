process SAMTOOLS_SORT {
    container 'quay.io/biocontainers/samtools:1.9--h91753b0_8'
    input:
    path sam_file

    output:
    path sorted_bam

    script:
    bam_file = "${sam_file.baseName}.bam"
    tmp_file = "${sam_file.baseName}.tmp.sort"
    sorted_bam = "${sam_file.baseName}_sorted.bam"
    """
    mkdir -p bam
    samtools view -uS -o bam/$bam_file $sam_file
    samtools sort -@ $task.cpus -T $tmp_file -o $sorted_bam bam/$bam_file
    """
}