process SAMTOOLS_SORT {
    conda 'bioconda::samtools=1.17'

    input:
    path sam_file

    output:
    path sorted_bam

    script:
    bam_file = "${sam_file.baseName}.bam"
    tmp_file = "${sam_file.baseName}.tmp.sort"
    sorted_bam = "${sam_file.baseName}_sorted.bam"
    """
    mkdir -p bam
    samtools view -uS -o bam/$bam_file $sam_file
    samtools sort -@ $task.cpus -T $tmp_file -o $sorted_bam bam/$bam_file
    """
}

/*
Align edilmiş sam dosyasını bam dosyasına dönüştürüyor, sonrasında bu bam dosyasını kromozomlara göre sıralıyor
Sıraladığı sam dosyasını döndürüyor
*/