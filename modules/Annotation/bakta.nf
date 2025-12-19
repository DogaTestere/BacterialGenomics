nextflow.enable.dsl = 2

process RUN_BAKTA {
    tag "${meta_id}"
    conda "bioconda::bakta=1.11.4"
    //publishDir "${params.outdir}/Annotation/Bakta", mode: 'copy' // Sonuçları buraya kopyalar

    input:
    tuple val(meta_id), path(assembly_fasta)
    path db_path

    output:
    path bakta_dir
    path bakta_gff
    path bakta_gbk
    path bakta_txt

    script:
    bakta_dir = "${meta_id}_Bakta_Results"
    bakta_gff = "${meta_id}_Bakta_Results/*.gff3"
    bakta_gbk = "${meta_id}_Bakta_Results/*.gbff"
    bakta_txt = "${meta_id}_Bakta_Results/*.txt"
    """
    bakta --db ${db_path} \
          --output ${meta_id}_Bakta_Results \
          --prefix ${meta_id} \
          --min-contig-length 200 \
          --threads ${task.cpus} \
          --force \
          ${assembly_fasta}
    """
}
