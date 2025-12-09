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

