
nextflow.enable.dsl = 2

// İşçiyi çağır
include { RUN_PROKKA } from './prokka.nf'

workflow PROKKA_FLOW {
    take:
    assembly_input

    main:
    prokka_out = RUN_PROKKA(assembly_input)

    emit:
    prokka_dir = prokka_out.prokka_dir
}
