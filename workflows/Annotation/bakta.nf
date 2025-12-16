nextflow.enable.dsl = 2

process RUN_BAKTA {
    tag "${meta_id}"
    conda "${projectDir}/bioenv.yaml" 
    publishDir "${params.outdir}/Annotation/Bakta", mode: 'copy'

    input:
    tuple val(meta_id), path(assembly_fasta)
    path db_path

    output:
    path "${meta_id}_Bakta_Results", emit: bakta_dir
    path "${meta_id}_Bakta_Results/*.gff3", emit: bakta_gff
    path "${meta_id}_Bakta_Results/*.gbff", emit: bakta_gbk
    path "${meta_id}_Bakta_Results/*.txt", emit: bakta_txt

    script:
    """
    # Bakta çalıştırma komutu
    # --skip-plot: Hızlandırmak için grafiği atlıyoruz
    
    bakta --db ${db_path} \
          --output ${meta_id}_Bakta_Results \
          --prefix ${meta_id} \
          --min-contig-length 200 \
          --threads 2 \
          --force \
          ${assembly_fasta}
    """
}
