// The matching files are emitted as tuples in which the first element is the grouping key of the matching pair and the second element is the list of files 
// flat: When true the matching files are produced as sole elements in the emitted tuples (default: false).

process BOWTIE_ALIGNMENT {
    // Aligns the reads to the indexed files. Reads must come as a flattened tuple for accessing them easily
    // Returns the sam file path with the file name being the first sample's name
    input:
    path(index_path)
    tuple path(ref_file), path(fastq_files)

    output:
    path (sam_file)

    script:
    sam_file = "${fastq_files[0].baseName}"
    """
    bowtie2 -x ${index_path}/${ref_file.baseName} \
    -1 ${fastq_files[0]} \
    -2 ${fastq_files[1]} \
    -S ${sam_file}
    """
}