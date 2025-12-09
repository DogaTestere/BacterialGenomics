include { BOWTIE_ALIGNMENT } from "../../modules/Assembly/refAlignment"
include { BOWTIE_INDEXING } from "../../modules/Assembly/refIndexing"
include { SAMTOOLS_SORT } from "../../modules/Assembly/bamConversion"
include { SAMTOOLS_INDEX } from "../../modules/Assembly/bamIndexing"
include { BCFTOOLS_CALL } from "../../modules/Assembly/variantCalling"
include { BCFTOOLS_INDEX } from "../../modules/Assembly/vcfIndexing"
include { BCFTOOLS_CONCENSUS } from "../../modules/Assembly/concensusCreation"

workflow REFERENCE_ASSEMBLY{
    take:
    trimmed_ch
    
    main:
    ref_ch = channel.fromPath(params.ref_file, checkIfExists: true)

    // Pipeline steps
    indexed_ref = BOWTIE_INDEXING(ref_ch)
    aligned_bam = BOWTIE_ALIGNMENT(indexed_ref, trimmed_ch)
    sorted_bam = SAMTOOLS_SORT(aligned_bam)
    indexed_bam = SAMTOOLS_INDEX(sorted_bam)
    variant_bcf = BCFTOOLS_CALL(ref_ch, sorted_bam, indexed_bam)
    indexed_vcf = BCFTOOLS_INDEX(variant_bcf)
    concensus_fastq = BCFTOOLS_CONCENSUS(indexed_vcf, ref_ch)

    emit:
        indexed_ref
        aligned_bam
        sorted_bam
        indexed_bam
        variant_bcf
        indexed_vcf
        concensus_fastq
}