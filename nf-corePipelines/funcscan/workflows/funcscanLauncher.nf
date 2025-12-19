include { FUNCSCAN_PİPELİNE } from "../modules/funcscan.nf"

workflow RUN_FUNSCAN {
    take:
    assembly_fasta

    main:
   samplesheet_ch = assembly_fasta
        .map { fasta ->
            def sample = fasta.parent.baseName
            "${sample},${fasta}\n"
        }
        .collectFile(
            name: 'assembly_fasta.csv',
            seed: 'sample,fasta\n'
        )
        
    funscan_dir = FUNCSCAN_PİPELİNE(samplesheet_ch, file(params.config_script))

    emit:
    funscan_dir
}

/*
reference guiaded assembly workflow(REFERENCE_ASSEMBLY) gives a fasta file, bcs it is used as a fasta file in other workflows.
So conversion of fasta file & it's location into a sample sheet should be in this workflow instead

NOTE: def is needed for naming variables that are inside a closure
--> Variables in a closure should be declared with `def`

funscan normally has a results directory itself, but since it is being run as a process, it needs to send that directory back, otherwise it would be under the work/ direcotry instead of being published
*/