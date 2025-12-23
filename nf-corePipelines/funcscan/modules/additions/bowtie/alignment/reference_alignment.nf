process BOWTIE_ALIGNMENT {  
    container "quay.io/biocontainers/bowtie2:2.5.4--he96a11b_7"
    input:
    path(index_path)
    tuple val(sample_id), path(fastq_files)

    output:
    path (sam_file)

    script:
    sam_file = "${sample_id}.sam"
    """
    prefix=\$(cat ${index_path}/prefix.txt)

    bowtie2 \
        -x ${index_path}/\$prefix \
        -1 ${fastq_files[0]} \
        -2 ${fastq_files[1]} \
        -S ${sam_file}
    """
}