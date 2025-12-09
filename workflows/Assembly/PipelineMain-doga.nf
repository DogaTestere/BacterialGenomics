include { BOWTIE_ALIGNMENT } from "../../modules/Assembly/refAlignment"
include { BOWTIE_INDEXING } from "../../modules/Assembly/refIndexing"
include { SAMTOOLS_SORT } from "../../modules/Assembly/bamConversion"
include { SAMTOOLS_INDEX } from "../../modules/Assembly/bamIndexing"
include { BCFTOOLS_CALL } from "../../modules/Assembly/variantCalling"
include { BCFTOOLS_INDEX } from "../../modules/Assembly/vcfIndexing"
include { BCFTOOLS_CONCENSUS } from "../../modules/Assembly/concensusCreation"

workflow {
    main:
    ref_ch = channel.fromPath(params.ref_file, checkIfExists: true)
    fastq_ch = channel.fromFilePairs(params.fastq_files, checkIfExists: true)


    // Can'nın pipeline sonucu olan {sample}_R1 ve {sample}_R2 paired sonuçları lazım
    // trimmed/ adlı bir klasör içinde olucak sonuçlar
    // Şuanlık kapalı, normalde fastq_ch yerine bu kullanılıcak
    //trimms_ch = channel.fromFilePairs()

    // Geçici trimm channel ı, results klasöründeki yolu kullanıyor
    trimms_ch = channel.fromFilePairs(params.trimmed, checkIfExists: true)

    // Pipeline steps
    indexed_ref = BOWTIE_INDEXING(ref_ch)
    aligned_bam = BOWTIE_ALIGNMENT(indexed_ref, trimms_ch)
    sorted_bam = SAMTOOLS_SORT(aligned_bam)
    indexed_bam = SAMTOOLS_INDEX(sorted_bam)
    variant_bcf = BCFTOOLS_CALL(ref_ch, sorted_bam, indexed_bam)
    indexed_vcf = BCFTOOLS_INDEX(variant_bcf)
    concensus_fastq = BCFTOOLS_CONCENSUS(indexed_vcf, ref_ch)

    publish:
    indexed_ref = indexed_ref
    aligned_bam = aligned_bam
    sorted_bam = sorted_bam
    indexed_bam = indexed_bam
    variant_bcf = variant_bcf
    indexed_vcf = indexed_vcf
    concensus_fastq = concensus_fastq
}

output {
    indexed_ref {
        path "./ModuleSteps/bowtie/indexing"
    }
    aligned_bam {
        path "./ModuleSteps/bowtie/alignment"
    }
    sorted_bam {
        path "./ModuleSteps/samtools/sorting"
    }
    indexed_bam {
        path "./ModuleSteps/samtools/indexing"
    }
    variant_bcf {
        path "./ModuleSteps/bcftools/collapsing"
    }
    indexed_vcf {
        path "./ModuleSteps/bcftools/indexing"
    }
    concensus_fastq {
        path "./Moduleresults/concensus"
    }
}