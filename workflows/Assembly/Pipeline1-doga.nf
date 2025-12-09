include { BOWTIE_ALIGNMENT } from "../../modules/Assembly/refAlignment.nf"
include { BOWTIE_INDEXING } from "../../modules/Assembly/refIndexing.nf"
include { SAMTOOLS_SORT } from "../../modules/Assembly/bamConversion.nf"

workflow Pipeline1 {
    main:
    fastq_ch = channel.fromFilePairs(params.fastq_files, flat:true)
    ref_ch = channel.fromPath(params.ref_file)

    combined_ch = ref_ch.combine(fastq_ch)

    indexed_ref = BOWTIE_INDEXING(ref_ch)
    aligned_sam = BOWTIE_ALIGNMENT(indexed_ref, combined_ch)
    sorted_bam = SAMTOOLS_SORT(aligned_sam)
    
    emit:
    sorted_bam_out = sorted_bam
}

output {
    indexed_ref {
        path "./Assembly/Bowtie/Indexing"
    }
    aligned_sam {
        path "./Assembly/Bowtie/Alignment"
    }
    sorted_bam {
        path "./Assembly/Samtools/Sorting"
    }
}