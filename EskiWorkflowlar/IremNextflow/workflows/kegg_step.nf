nextflow.enable.dsl = 2

process RUN_KEGG {
    tag "${meta_id}"
    conda "${projectDir}/bioenv.yaml"

    input:
    tuple val(meta_id), path(prokka_dir)

    output:
    tuple val(meta_id), path("${meta_id}_final_report.xlsx"), emit: kegg_excel

    script:
    """
    python3 ${projectDir}/scripts/KEGG_prokka_nf.py \
    --input ${prokka_dir}/${meta_id}.txt \
    --output ${meta_id}_final_report.xlsx
    """
}
