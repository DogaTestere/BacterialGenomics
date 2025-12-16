
nextflow.enable.dsl = 2

include { RUN_KEGG } from './kegg_step.nf'

workflow KEGG_FLOW {
    take:
    prokka_dir

    main:
    kegg_out = RUN_KEGG(prokka_dir)

    emit:
    kegg_excel = kegg_out.kegg_excel
}
