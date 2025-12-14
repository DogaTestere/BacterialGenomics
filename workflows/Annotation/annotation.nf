nextflow.enable.dsl = 2

// 1. ADIM: Prokka ile Gen Bulma
process RUN_PROKKA {
    tag "${meta_id}"
    // Conda ortamını kullan
    conda "${projectDir}/bioenv.yaml" 

    input:
    tuple val(meta_id), path(assembly_fasta)

    output:
    tuple val(meta_id), path("${meta_id}_prokka_out"), emit: prokka_dir

    script:
    """
    prokka --outdir ${meta_id}_prokka_out --prefix ${meta_id} ${assembly_fasta} --force
    """
}

// 2. ADIM: Python ile Görselleştirme ve Raporlama
process VISUALIZE_RESULTS {
    tag "${meta_id}"
    conda "${projectDir}/bioenv.yaml"

    input:
    tuple val(meta_id), path(prokka_dir)

    output:
    path("${meta_id}_final_results"), emit: final_output

    script:
    """
    # Klasör hazırla ve Prokka dosyalarını kopyala
    mkdir -p ${meta_id}_final_results
    cp -r ${prokka_dir}/* ${meta_id}_final_results/

    # 1. KEGG Scripti (Excel üretir)
    python3 ${projectDir}/scripts/KEGG_prokka_nf.py --input ${prokka_dir}/${meta_id}.txt --output ${meta_id}_final_results/final_report.xlsx

    # 2. Grafik Scripti (Renkli grafikler üretir)
    python3 ${projectDir}/scripts/plot_prokka.py --input ${meta_id}_final_results/final_report.xlsx --output_dir ${meta_id}_final_results/Visualizations
    """
}

// 3. ADIM: İş Akışını Bağla
workflow ANNOTATION_FLOW {
    take:
    assembly_input

    main:
    prokka_results = RUN_PROKKA(assembly_input)
    final_results = VISUALIZE_RESULTS(prokka_results.prokka_dir)

    emit:
    annotated_output = final_results.final_output
}
