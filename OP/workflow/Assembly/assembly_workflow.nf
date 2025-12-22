include { SPADES_ASSEMBLY } from '../../process/Assembly/spades.nf'

workflow ASSEMBLY_PIPELINE {

    take:
        trimmed_fastq_ch

    main:

        // 1) R1 ve R2'yi ayır
        r1_ch = trimmed_fastq_ch.map { sample, r1, r2 -> tuple(sample, r1) }
        r2_ch = trimmed_fastq_ch.map { sample, r1, r2 -> tuple(sample, r2) }

        // 2) combine
        combined = r1_ch.combine(r2_ch)

        // 3) combine sonrası tuple'ı DÜZELT
        paired_reads = combined.map { s1, r1, s2, r2 -> tuple(s1, r1, r2) }

        // 4) SPAdes
        spades_output = SPADES_ASSEMBLY(paired_reads)

        // 5) collect
        collected_assemblies = spades_output.collect()

    emit:
        assembly_out = collected_assemblies
}

