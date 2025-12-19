include { TRIMMING_PIPELINE } from "./workflows/cutadapt.nf"
include { REFERENCE_ASSEMBLY } from "./workflows/referenceAssembly.nf"
include { RUN_FUNSCAN } from "./workflows/funcscanLauncher.nf"

workflow {
    main:

    cutadapt_out = TRIMMING_PIPELINE()
    reference_out = REFERENCE_ASSEMBLY(cutadapt_out.trimmed_shaped)
    funscan_out = RUN_FUNSCAN(reference_out.reference_fasta)

    publish:
    cutadapt = cutadapt_out.trimmed_shaped
    assembly_fasta = reference_out.reference_fasta
    funscan_res = funscan_out.funscan_dir
}

output {
    cutadapt {
        path "./cutadapt"
    }
    assembly_fasta {
        path "./referenceAssembly"
    }
    funscan_res {
        path ""
    }
}