include { SAMTOOLS_INDEX } from "../../modules/Assembly/bamIndexing.nf"
include { BCFTOOLS_CALL } from "../../modules/Assembly/variantCalling.nf"
include { BCFTOOLS_INDEX } from "../../modules/Assembly/vcfIndexing.nf"
include { Pipeline1 } from './Pipeline1-doga.nf'

workflow Pipeline2 {
    main:
    ref_ch = channel.fromPath(params.ref_file)
    pipeline1_out = Pipeline1()
    sorted_bam = pipeline1_out.sorted_bam_out

    indexed_bam = SAMTOOLS_INDEX(sorted_bam)
    variant_bcf = BCFTOOLS_CALL(ref_ch, indexed_bam)
    indexed_vcf = BCFTOOLS_INDEX(variant_bcf)

    emit:
    indexed_vcf_out = indexed_vcf
}

output {
    indexed_bam {
        path "./Assembly/Samtools/Indexing"
    }
    variant_bcf {
        path "./Assembly/Bcftools/Calling"
    }
    indexed_vcf {
        path "./Assembly/Bcftools/Indexing"
    }
}