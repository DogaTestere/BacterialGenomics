#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/funcscan
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/funcscan
    Website: https://nf-co.re/funcscan
    Slack  : https://nfcore.slack.com/channels/funcscan
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FUNCSCAN                } from './workflows/funcscan'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_funcscan_pipeline'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_funcscan_pipeline'


include { REFERENCE_ASSEMBLY      } from './subworkflows/additions/assembly/reference_assembly'
include { TRIMMING_PIPELINE       } from './subworkflows/additions/quality_control/trimming'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline
//
workflow NFCORE_FUNCSCAN {
    take:
    //samplesheet // channel: samplesheet read in from --input
    reference_sheet // path: samplesheet read 

    main:
    //
    // WORKFLOW: Run pipeline
    //
    FUNCSCAN (
        //samplesheet
        reference_sheet
    )
    emit:
    multiqc_report = FUNCSCAN.out.multiqc_report // channel: /path/to/multiqc_report.html
}

workflow QC_ASSEMBLY {
    main:

    trim_out = TRIMMING_PIPELINE()
    samplesheet = REFERENCE_ASSEMBLY(trim_out.trimmed_shaped)

    emit:
    samplesheet
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:
    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        //params.input
    )

    //
    // WORKFLOW: Run main workflow
    //

    QC_ASSEMBLY()

    // 2. Create the Channel (FIXED STRUCTURE)
    ch_funcscan_input = QC_ASSEMBLY.out.samplesheet
        .splitCsv(header: true)
        .map { row ->
            def meta = [id: row.sample] 
            def fasta_file = file(row.fasta)
            
            // CRITICAL FIX: Add empty lists [] for the missing 'faa' and 'gbk' slots
            // Structure: [ meta, fasta, faa, gbk ]
            return [ meta, fasta_file, [], [] ] 
        }

    NFCORE_FUNCSCAN (
        //PIPELINE_INITIALISATION.out.samplesheet
        ch_funcscan_input
    )
    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
        NFCORE_FUNCSCAN.out.multiqc_report
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/