nextflow.enable.dsl = 2

process TRIMMING {

    input:
        tuple val(sample), path(read1), path(read2)

    output:
        tuple val(sample),
              path("trimmed/${sample}_R1_paired.fastq.gz"),
              path("trimmed/${sample}_R2_paired.fastq.gz")

    script:
    """
    mkdir -p trimmed

    cutadapt \
      -q 20,20 \
      -m 36 \
      -o trimmed/${sample}_R1_paired.fastq.gz \
      -p trimmed/${sample}_R2_paired.fastq.gz \
      ${read1} ${read2}
    """
}
