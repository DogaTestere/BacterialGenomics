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
    main:
    //fastq_ch = Channel.fromPath("/home/cangercek/*_R{1,2}_001.fastq.gz")

    fastq_ch = channel.fromPath("./DogaNextflow/FastqFiles/*_R{1,2}_001.fastq.gz")

    fastqc_results = FASTQC(fastq_ch)

    publish:
    fastqc_results = fastqc_results
}

output {
    fastqc_results {
        path "./fastqc"
    }
}