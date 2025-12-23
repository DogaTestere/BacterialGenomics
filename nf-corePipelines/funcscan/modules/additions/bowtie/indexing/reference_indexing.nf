process BOWTIE_INDEXING {
    container "quay.io/biocontainers/bowtie2:2.5.4--he96a11b_7"
    input:
    path ref_file

    output:
    path("ref_index")

    script:
    base_name = "${ref_file.baseName}"
    """
    mkdir -p ref_index
    bowtie2-build --threads $task.cpus $ref_file ref_index/$base_name

    echo "$base_name" > ref_index/prefix.txt
    """
}