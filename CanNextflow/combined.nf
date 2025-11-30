nextflow.enable.dsl = 2

process FASTQC {

    input:
    path reads

    output:
    path "results_fastqc"

    script:
    """
    mkdir -p results_fastqc
    fastqc ${reads} -o results_fastqc
    """
}


process TRIMMING {

    input:
    tuple val(sample), path(read1), path(read2)

    output:
    path "trimmed/${sample}_R1_paired.fastq.gz"
    path "trimmed/${sample}_R1_unpaired.fastq.gz"
    path "trimmed/${sample}_R2_paired.fastq.gz"
    path "trimmed/${sample}_R2_unpaired.fastq.gz"

    script:
    """
    mkdir -p trimmed
    trimmomatic PE -threads 4 \
      ${read1} ${read2} \
      trimmed/${sample}_R1_paired.fastq.gz trimmed/${sample}_R1_unpaired.fastq.gz \
      trimmed/${sample}_R2_paired.fastq.gz trimmed/${sample}_R2_unpaired.fastq.gz \
      LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36
    """
}

workflow {

    fastq_ch = Channel.fromPath("/home/cangercek/*_R{1,2}_001.fastq.gz")

    FASTQC(fastq_ch)

    trım_ch = Channel.fromFilePairs("/home/cangercek/*_R{1,2}_001.fastq.gz", flat: true)

    TRIMMING(trım_ch)
}
