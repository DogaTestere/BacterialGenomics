process MAKE_ASSEMBLY_SAMPLESHEET {

    tag "assembly_samplesheet"

    input:
    path fasta

    output:
    path "assembly_fasta.csv"

    script:
    // Use readlink -f to get the absolute path of the input fasta
    """
    echo "sample,fasta" > assembly_fasta.csv
    echo "${fasta.baseName},\$(readlink -f ${fasta})" >> assembly_fasta.csv
    """
}
