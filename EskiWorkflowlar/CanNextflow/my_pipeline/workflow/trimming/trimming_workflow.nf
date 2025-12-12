/* TRIMMING PIPELINE
   3 mantıksal adım:
   1) Paired-end FASTQ dosyalarını kanala almak
   2) TRIMMING process'ini çalıştırmak
   3) Trimlenmiş FASTQ dosyalarını emit etmek
*/

include { TRIMMING } from '../../process/trimming/trimming.nf'

workflow TRIMMING_PIPELINE {

    main:

    // 1) Paired-end input channel (ham fastq dosyalarını okur)
    pe_ch = channel.fromFilePairs(params.fastq_files, flat:true)

    // 2) Trimming step
    trimmed = TRIMMING(pe_ch)

    // 3) Output olarak trimlenmiş dosyaları emit et
    emit:
        trimmed_fastq_out = trimmed
}

