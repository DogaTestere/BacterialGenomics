
nextflow.enable.dsl = 2

include { VISUALIZE_RESULTS } from '../../modules/GraphCreation/visualize.nf'

workflow PLOTTING_FLOW {
    take:
    kegg_excel
    prokka_dir

    main:
    // İki veriyi birleştirip çizime yolluyoruz
    plotting_inputs = kegg_excel.join(prokka_dir)
    final_folder = VISUALIZE_RESULTS(plotting_inputs, file(params.prokka_graph_script))

    emit:
    final_folder
}

