process annotate_genome {

    input:
    path genome_fasta

    output:
    path "annotation_output"

    script:
    """
    prokka --outdir annotation_output \
           --prefix annotation_result \
           --force \
           $genome_fasta
    """
}

workflow {

    params.input_fasta = '/mnt/c/Users/Dell/OneDrive/Masaüstü/e_coli_model/e_coli.fasta'

    fasta_channel = Channel.fromPath(params.input_fasta)

    annotate_genome(fasta_channel)
}
