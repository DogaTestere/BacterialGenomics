
nextflow.enable.dsl = 2

// İşçiyi çağır
include { ANNOTATE_GENOME } from '../../modules/Annotation/prokka.nf'

workflow PROKKA_FLOW {
    take:
    assembly_input

    main:
    prokka_dir = ANNOTATE_GENOME(assembly_input)

    emit:
    prokka_dir
}
