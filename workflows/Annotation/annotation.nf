include { ANNOTATE_GENOME } from '../../modules/Annotation/prokka.nf'

workflow ANNOTATION_FLOW {
    take:
    consensus_seq_ch

    main:
    ANNOTATE_GENOME(consensus_seq_ch)

    emit:
    annotated_output = ANNOTATE_GENOME.out.annotation_dir
}
