process ANNOTATE_GENOME {
    tag "$genome_fasta.baseName"
    publishDir "results/annotation", mode: 'copy'

    input:
    path genome_fasta

    output:
    path "${genome_fasta.baseName}_anno", emit: annotation_dir

    script:
    """
    mkdir ${genome_fasta.baseName}_anno
    prokka --outdir ${genome_fasta.baseName}_anno \
           --prefix ${genome_fasta.baseName} \
           --force \
           --cpus ${task.cpus} \
           $genome_fasta
    """
}
