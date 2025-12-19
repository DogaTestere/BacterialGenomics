include { CUTADAPT } from "../modules/cutadapt.nf"
workflow TRIMMING_PIPELINE {
    main:
    pe_ch = channel.fromFilePairs(params.fastq_files, flat:true)

    trimmed = CUTADAPT(pe_ch)

    // Ek: Bowtie Alignment dosyları [sample_id [sample, sample]] şeklinde istiyor bunun için dönüştürme yapılması lazım
    trimmed_reshaped = trimmed.map { sample, read1, read2 -> tuple(sample, [read1, read2])}

    emit:
        trimmed_shaped = trimmed_reshaped
}