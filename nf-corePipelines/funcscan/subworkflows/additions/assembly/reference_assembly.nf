include { BOWTIE_ALIGNMENT } from "../../../modules/additions/bowtie/alignment/reference_alignment.nf"
include { BOWTIE_INDEXING } from "../../../modules/additions/bowtie/indexing/reference_indexing"
include { SAMTOOLS_SORT } from "../../../modules/additions/samtools/sort/bam_conversion"
include { SAMTOOLS_INDEX } from "../../../modules/additions/samtools/index/bam_indexing"
include { BCFTOOLS_CALL } from "../../../modules/additions/bcftools/pileup/variant_calling"
include { BCFTOOLS_INDEX } from "../../../modules/additions/bcftools/index/vcf_indexing"
include { BCFTOOLS_CONCENSUS } from "../../../modules/additions/bcftools/concensus/concensus_creation"
include { MAKE_ASSEMBLY_SAMPLESHEET } from "../../../modules/additions/samplesheet_maker"

workflow REFERENCE_ASSEMBLY{
    take:
    fastq_channel
    
    main:
    ref_ch = channel.fromPath("./example_files/*_genomic.fna", checkIfExists: true)

    // Pipeline steps
    indexed_ref = BOWTIE_INDEXING(ref_ch)
    aligned_bam = BOWTIE_ALIGNMENT(indexed_ref, fastq_channel)
    sorted_bam = SAMTOOLS_SORT(aligned_bam)
    indexed_bam = SAMTOOLS_INDEX(sorted_bam)
    variant_bcf = BCFTOOLS_CALL(ref_ch, sorted_bam, indexed_bam)
    indexed_vcf = BCFTOOLS_INDEX(variant_bcf)
    assembly_fasta = BCFTOOLS_CONCENSUS(indexed_vcf, ref_ch)

    samplesheet = MAKE_ASSEMBLY_SAMPLESHEET(assembly_fasta)

    emit:
        samplesheet

}