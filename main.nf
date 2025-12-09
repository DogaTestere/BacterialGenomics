nextflow.enable.dsl = 2

include { QC_PIPELINE }        from './workflows/workflow/QC/qc_workflow.nf'
include { TRIMMING_PIPELINE }  from './workflows/workflow/trimming/trimming_workflow.nf'
include { ASSEMBLY_PIPELINE }  from './workflows/workflow/Assembly/assembly_workflow.nf'

workflow {

    // 1) QC: sadece FASTQC (raw)
    qc_out = QC_PIPELINE()

    // 2) TRIMMING: ham fastqlardan trim
    trim_out = TRIMMING_PIPELINE()

    // 3) ASSEMBLY: trimlenmiş veriden SPAdes
    ASSEMBLY_PIPELINE(trim_out.trimmed_fastq_out)
}

