process BCFTOOLS_CONCENSUS {
    input:
    tuple path(zipped_file), path(indexed_vcf)
    path ref_file

    output:
    path concensus_file

    script:
    def clean_name = zipped_file.getName()
                        .replace('_sorted', '')
                        .replace('.vcf.gz', '')

    concensus_file = "${clean_name}.fasta"

    "bcftools consensus -f $ref_file $zipped_file > $concensus_file"
}

/*
Referans dosyasını kalıp olarak kullanarak vcf dosyasında belirtilen değişikleri gerçekleştiriyor sonuç olarak ise tam bir genomu veriyor
*/