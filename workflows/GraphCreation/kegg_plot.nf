
nextflow.enable.dsl = 2

include { RUN_PLOTTING } from './visualize.nf'

workflow PLOTTING_FLOW {
    take:
    kegg_excel
    prokka_dir

    main:
    // İki veriyi birleştirip çizime yolluyoruz
    plotting_inputs = kegg_excel.join(prokka_dir)
    final_out = RUN_PLOTTING(plotting_inputs)

    emit:
    final_folder = final_out.final_folder
}

