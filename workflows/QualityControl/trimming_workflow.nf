/* TRIMMING PIPELINE
   3 mantıksal adım:
   1) Paired-end FASTQ dosyalarını kanala almak
   2) TRIMMING process'ini çalıştırmak
   3) Trimlenmiş FASTQ dosyalarını emit etmek
*/

include { TRIMMING } from '../../modules/QualityControl/trimming.nf'

workflow TRIMMING_PIPELINE {

    main:

    // 1) Paired-end input channel (ham fastq dosyalarını okur)
    pe_ch = Channel.fromFilePairs(params.fastq_files, flat:true)

    // 2) Trimming step
    trimmed = TRIMMING(pe_ch)

    // Ek: Bowtie Alignment dosyları [sample_id [sample, sample]] şeklinde istiyor bunun için dönüştürme yapılması lazım
    trimmed_reshaped = trimmed.map { sample, read1, read2 -> tuple(sample, [read1, read2])}

    // 3) Output olarak trimlenmiş dosyaları emit et
    emit:
        trimmed_raw = trimmed
        trimmed_shaped = trimmed_reshaped
}

