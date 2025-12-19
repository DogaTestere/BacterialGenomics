process SAMTOOLS_INDEX {
    input:
    path sorted_bam

    output:
    path index_bam

    script:
    index_bam = "${sorted_bam.baseName}.bam.bai"
    "samtools index $sorted_bam"
}
/*
Hizalanmış bam dosyasını indexleyip index dosyasını döndürüyor
*/