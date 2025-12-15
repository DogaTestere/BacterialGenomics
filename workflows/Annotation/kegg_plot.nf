nextflow.enable.dsl = 2

process RUN_PLOTTING {
    tag "${meta_id}"
    conda "${projectDir}/bioenv.yaml"

    input:
    tuple val(meta_id), path(kegg_excel), path(prokka_dir)

    output:
    path("${meta_id}_Annotation_Results"), emit: final_folder

    script:
    """
    mkdir -p ${meta_id}_Annotation_Results
    cp -r ${prokka_dir}/* ${meta_id}_Annotation_Results/
    cp ${kegg_excel} ${meta_id}_Annotation_Results/

    python3 ${projectDir}/scripts/plot_prokka.py \
    --input ${kegg_excel} \
    --output_dir ${meta_id}_Annotation_Results/Visualizations
    """
}
