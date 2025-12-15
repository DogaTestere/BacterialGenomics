nextflow.enable.dsl = 2

process RUN_PROKKA {
    tag "${meta_id}"
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
