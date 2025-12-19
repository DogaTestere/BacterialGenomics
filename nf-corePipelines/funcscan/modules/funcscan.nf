process FUNCSCAN_PİPELİNE {
    input:
    path samplesheet_ch
    path config_file

    output:
    path "runscanResults"
    
    script:
    """
    nextflow run nf-core/funcscan \
        -profile docker \
        --input $samplesheet_ch \
        --outdir runscanResults \
        --run_amp_screening \
        --run_arg_screening \
        --run_bgc_screening \
        -c $config_file
    """
}

/*
emit: <name>
    Defines the name of the output channel.
*/