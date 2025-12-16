
nextflow.enable.dsl = 2

include { RUN_KEGG_ANALYSIS } from '../../modules/Annotation/kegg_analiz.nf'

workflow KEGG_FLOW {
    take:
    prokka_dir

    main:
    kegg_excel = RUN_KEGG_ANALYSIS(prokka_dir, file(params.kegg_analysis_script))

    emit:
    kegg_excel
}
