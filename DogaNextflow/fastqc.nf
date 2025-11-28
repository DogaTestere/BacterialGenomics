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

workflow {

    fastq_ch = Channel.fromPath("/home/cangercek/*_R{1,2}_001.fastq.gz")

    FASTQC(fastq_ch)
}
