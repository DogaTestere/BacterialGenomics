include { SPADES_ASSEMBLY } from '../../process/Assembly/spades.nf'

workflow ASSEMBLY_PIPELINE {

    take:
        trimmed_fastq_ch

    main:
        spades_output = SPADES_ASSEMBLY(trimmed_fastq_ch)

    emit:
        assembly_out = spades_output
}
