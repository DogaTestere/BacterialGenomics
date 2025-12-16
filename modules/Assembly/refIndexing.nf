process BOWTIE_INDEXING {
    conda 'bioconda::bowtie2=2.5.1'
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

/*
Referans dosyasını indexliyor ve bulunduğu klasörü döndürüyor. Bu sırada reference dosyasının adını prefix olarak kullanıyor
Prefix olarak kullanılan isim ref_index içinde tutuluyor ve alignment için kullanılacak

$task.cpus <-- Kısmı nextflow.config içerisinde belirleniyor
ref_file <-- Ana pipeline içersinde params. ile belirleniyor
*/
