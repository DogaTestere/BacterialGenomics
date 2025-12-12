nextflow.enable.dsl = 2

include { QC_PIPELINE }        from './workflows/QualityControl/qc_workflow.nf'
include { TRIMMING_PIPELINE }  from './workflows/QualityControl/trimming_workflow.nf'
include { ASSEMBLY_PIPELINE }  from './workflows/Assembly/assembly_workflow.nf'

include { REFERENCE_ASSEMBLY } from "./workflows/Assembly/referenceAssembly"

include { ANNOTATION_FLOW }    from './workflows/Annotation/annotation.nf'

include { VCF_GRAPH_CREATION } from "./workflows/GraphCreation/vcfQuality"

workflow {
    main:
    // 1) QC: sadece FASTQC (raw)
    qc_out = QC_PIPELINE()

    // 2) TRIMMING: ham fastqlardan trim
    trim_out = TRIMMING_PIPELINE()

    /*
    TRIMMING_PIPELINE 2 adet sonuç çıkartıyor biri düz {sample, read1, read2} channel = trimmed_raw
    Diğeri ise {sample, [read1, read2]} = trimmed_shaped
    Farklı olmalarının nedeni REFERENCE_ASSEMBLY kısmında BOWTIE_ALIGNMENT adımının sonuçları {sample, [read1, read2]} bu şekilde beklemesi, eğer sonuçlar farklı bir şekilde gelirse kod çalışmıyor
    */

    // 3) ASSEMBLY: trimlenmiş veriden SPAdes
    assembly_out = ASSEMBLY_PIPELINE(trim_out.trimmed_raw)

    // 3.A) ASSEMBLY: Trimlenmiş veriden Bcftools ile Assembly(Reference Guided Assembly)
    reference_out = REFERENCE_ASSEMBLY(trim_out.trimmed_shaped)

    //Prokka kısmı
    //annotation_out = ANNOTATION_FLOW(reference_out.concensus_fastq)

    // 5) VCF Dosyasında Kalite Değerlerini Gösteren Graph Oluşturma
    vcf_graph_out = VCF_GRAPH_CREATION(reference_out.indexed_vcf)

    publish:
    fastqc_results = qc_out.raw_fastqc_out
    // Trimmomatic outputları
    trimmed_files = trim_out.trimmed_raw
    // deNovo Assembly Outputları
    denovo_assembly = assembly_out.assembly_out
    // Reference Assembly Outputları
    indexed_ref = reference_out.indexed_ref
    aligned_bam = reference_out.aligned_bam
    sorted_bam = reference_out.sorted_bam
    indexed_bam = reference_out.indexed_bam
    variant_bcf = reference_out.variant_bcf
    indexed_vcf = reference_out.indexed_vcf
    reference_assembly = reference_out.concensus_fastq
    // Annotation Outputları
    //annotated_dir = annotation_out.annotated_output
    // Grafik Oluşturma Outputları
    depth_graph = vcf_graph_out.depth_png
    qual_graph = vcf_graph_out.qual_png
}

output {
    indexed_ref {
        path "./bowtie/indexing"
    }
    aligned_bam {
        path "./bowtie/alignment"
    }
    sorted_bam {
        path "./samtools/sorting"
    }
    indexed_bam {
        path "./samtools/indexing"
    }
    variant_bcf {
        path "./bcftools/collapsing"
    }
    indexed_vcf {
        path "./bcftools/indexing"
    }
    reference_assembly {
        path "./referenceAssembly"
    }
    denovo_assembly {
        path "./denovoAssembly"
    }
    trimmed_files {
        path "./trimmomatic"
    }
    fastqc_results {
        path "./fastqc"
    }
    //annotated_dir {
    //    path "./annotation"
    //}
    depth_graph {
        path "./graphs/vcf"
    }
    qual_graph {
        path "./graphs/vcf"
    }
}
