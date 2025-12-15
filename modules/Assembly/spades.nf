nextflow.enable.dsl = 2

process SPADES_ASSEMBLY {

    conda 'bioconda::spades=3.15.5 conda-forge::python=3.9'

    input:
        tuple val(sample), path(read1), path(read2)
    output:
        tuple val(sample), path("spades_${sample}")
    script:
    """
    mkdir -p spades_${sample}
    spades.py \
      -1 ${read1} \
      -2 ${read2} \
      -o spades_${sample}
    """
}
