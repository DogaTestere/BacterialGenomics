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
    main:
    //params.input_fasta = '/mnt/c/Users/Dell/OneDrive/Masaüstü/e_coli_model/e_coli.fasta'
    // config de bu oluşucak ^

    fasta_ch = channel.fromPath("./results/*.fasta", checkIfExists:true)

    //fasta_channel = Channel.fromPath(params.input_fasta)

    //annotate_genome(fasta_channel)
    annoted_dir = annotate_genome(fasta_ch)

    publish:
    annoted_dir = annoted_dir
}

output {
    annoted_dir {
        path "./annotation"
    }
}
