nextflow.enable.dsl=2

include { ANNOTATION_FLOW } from './workflows/annotation.nf'

workflow {
    // BURAYA DİKKAT: Test etmek için elindeki fasta dosyasını bulmamız lazım.
    // Aşağıdaki "./results/*.fasta" kısmı, results klasörüne koyacağın dosyayı arar.
    input_ch = Channel.fromPath("./results/*.fasta", checkIfExists: true)

    ANNOTATION_FLOW(input_ch)
}

