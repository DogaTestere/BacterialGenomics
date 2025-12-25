nextflow.enable.dsl = 2

process TRIMMING {
    conda "bioconda::trimmomatic"
    input:
        tuple val(sample), path(read1), path(read2)
    output:
        tuple val(sample),
             path("trimmed/${sample}_R1_paired.fastq.gz"),
             path("trimmed/${sample}_R2_paired.fastq.gz")
    script:
    """
    mkdir -p trimmed
    trimmomatic PE -threads 4 \
      ${read1} ${read2} \
      trimmed/${sample}_R1_paired.fastq.gz /dev/null \
      trimmed/${sample}_R2_paired.fastq.gz /dev/null \
      LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36
    """
}
