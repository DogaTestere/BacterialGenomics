nextflow.enable.dsl = 2

include { QC_PIPELINE }        from './workflows/QualityControl/qc_workflow.nf'
include { TRIMMING_PIPELINE }  from './workflows/QualityControl/trimming_workflow.nf'
include { ASSEMBLY_PIPELINE }  from './workflows/Assembly/assembly_workflow.nf'

include { REFERENCE_ASSEMBLY } from "./workflows/Assembly/PipelineMain-doga"

workflow {
    main:
    // 1) QC: sadece FASTQC (raw)
    qc_out = QC_PIPELINE()

    // 2) TRIMMING: ham fastqlardan trim
    trim_out = TRIMMING_PIPELINE()

    // 3) ASSEMBLY: trimlenmiş veriden SPAdes
    ASSEMBLY_PIPELINE(trim_out.trimmed_raw)

    // 3.A) ASSEMBLY: Trimlenmiş veriden Bcftools ile Assembly(Reference Guided Assembly)
    reference_out = REFERENCE_ASSEMBLY(trim_out.trimmed_shaped)

    publish:
    indexed_ref = reference_out.indexed_ref
    aligned_bam = reference_out.aligned_bam
    sorted_bam = reference_out.sorted_bam
    indexed_bam = reference_out.indexed_bam
    variant_bcf = reference_out.variant_bcf
    indexed_vcf = reference_out.indexed_vcf
    concensus_fastq = reference_out.concensus_fastq
}

output {
    indexed_ref {
        path "results/bowtie/indexing"
    }
    aligned_bam {
        path "results/bowtie/alignment"
    }
    sorted_bam {
        path "results/samtools/sorting"
    }
    indexed_bam {
        path "results/samtools/indexing"
    }
    variant_bcf {
        path "results/bcftools/collapsing"
    }
    indexed_vcf {
        path "results/bcftools/indexing"
    }
    concensus_fastq {
        path "results/concensus"
    }
}