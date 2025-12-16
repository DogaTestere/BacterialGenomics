process BOWTIE_ALIGNMENT {
    conda 'bioconda::bowtie2=2.5.1'
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

/*
Referans dosyasına göre trimmed veya trimmed olmayan readlerin hizalanmasını sağlıyor.
Fastq listesinden sample_id yi buluyor ve sam dosyasının adı olarak veriyor
prefix adını bulmak için bir önceki adımda oluşturulan text dosyası kullanılıyor

sample_id şunun gibi geliyor
[SRR493366, [/my/data/SRR493366_1.fastq, /my/data/SRR493366_2.fastq]]
yani tuple'daki ilk eleman sample_id, ikincisi ise file pair içeren liste
*/