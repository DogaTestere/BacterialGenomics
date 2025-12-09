/* QC PIPELINE
   Sadece 1 aşama:
   1) FASTQC raw reads
*/

include { FASTQC } from '../../modules/QualityControl/fastqc.nf'

workflow QC_PIPELINE {

    main:

    // 1) FASTQC raw reads
    raw_fastqc_ch = Channel.fromPath(params.fastq_files)
    raw_fastqc    = FASTQC(raw_fastqc_ch)

    emit:
        raw_fastqc_out = raw_fastqc
}
