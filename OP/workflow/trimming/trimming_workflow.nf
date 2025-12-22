include { TRIMMING } from '../../process/trimming/trimming.nf'

workflow TRIMMING_PIPELINE {

    main:

    // 1) Paired-end input channel
    pe_ch = Channel.fromFilePairs(params.fastq_files, flat: true)

    // 2) Branch: trim olacak / olmayacak ayır
    branched = pe_ch.branch {
        trim: true
        raw : true
    }

    // 3) Sadece trim kolu TRIMMING'e girer
    trimmed = TRIMMING(branched.trim)

    emit:
        trimmed_fastq_out = trimmed
}

