
nextflow.enable.dsl = 2

include { VISUALIZE_RESULTS } from '../../modules/GraphCreation/visualize.nf'

workflow PLOTTING_FLOW {
    take:
    kegg_excel    // Yapısı: [val(id), path(excel)] olmalı
    prokka_dir    // Yapısı: [val(id), path(dir)] olmalı

    main:
    // 1. Kanalları birleştir
    plotting_inputs = kegg_excel.join(prokka_dir)

    // DEBUG: Kanalın dolu olup olmadığını kontrol et (Loglarda görünür)
    plotting_inputs.view { "Birlestirilen Veri: $it" }

    // 2. Process'e yolla
    final_folder = VISUALIZE_RESULTS(plotting_inputs, file(params.prokka_graph_script))

    emit:
    final_folder
}
