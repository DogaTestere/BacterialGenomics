process BOWTIE_INDEXING {
    // Indexes the reference file and returns the index folder's name(ref_index)
    //Both reference file location and thread number to use comes from config
    input:
    path ref_file
    val thread_val

    output:
    tuple path("ref_index")

    script:
    base_name = "${ref_file.baseName}"
    """
    mkdir -p ref_index
    bowtie2-build --threads $thread_val $ref_file ref_index/$base_name
    """
}