nextflow.enable.dsl = 2

include { QC_PIPELINE }        from './workflow/QC/qc_workflow.nf'
include { TRIMMING_PIPELINE }  from './workflow/trimming/trimming_workflow.nf'
include { ASSEMBLY_PIPELINE }  from './workflow/Assembly/assembly_workflow.nf'

workflow {

    // 1) QC: sadece FASTQC (raw)
    qc_out = QC_PIPELINE()

    // 2) TRIMMING: ham fastqlardan trim,sonraki aşamada kullanılacağı için buna değişken atamak zorunlu.
    trim_out = TRIMMING_PIPELINE()

    // 3) ASSEMBLY: trimlenmiş veriden SPAdes
    ASSEMBLY_PIPELINE(trim_out.trimmed_fastq_out)
    //  assembly_out = ASSEMBLY_PIPELINE(trim_out.trimmed_fastq_out) şeklinde de yazabilirdik ama son aşama olduğu için yazmadık, parantez içindekiler input almasını sağlıyor.

}

