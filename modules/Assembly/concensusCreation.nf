process BCFTOOLS_CONCENSUS {
    // Creates a concensus sequence from vcf file and reference file then returns it
    // İndexed vcf file doesn't get used in the command but still if it's path is not know to this process, it gives an error
    input:
    tuple path(zipped_file), path(indexed_vcf)
    path ref_file

    output:
    path concensus_file

    script:
    concensus_file = "${zipped_file.baseName}.fasta"
    "bcftools consensus -f $ref_file $zipped_file > $concensus_file"
}