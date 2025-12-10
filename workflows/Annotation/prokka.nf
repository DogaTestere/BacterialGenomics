include { ANNOTATE_GENOME } from '../../modules/prokka.nf' 

workflow ANNOTATION_FLOW {
    // Burada gelen şeye "consensus_fasta" diyelim 
    take:
    consensus_fasta

    main:
    ANNOTATE_GENOME(consensus_fasta)

    emit:
    annotated_output = ANNOTATE_GENOME.out.annotation_dir
