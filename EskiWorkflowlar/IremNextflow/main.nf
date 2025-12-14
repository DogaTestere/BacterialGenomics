nextflow.enable.dsl=2

// Workflow'u çağırıyoruz
include { ANNOTATION_FLOW } from './workflows/annotation.nf'

workflow {
    // --- GİRİŞ DOSYASI (TEST İÇİN) ---
    // Results klasöründe duran ham fasta dosyasını kullanacağız.
    // (Senin ekran görüntüsünde "results/e_coli.fasta" vardı, onu kullanıyoruz)
    
    test_fasta = "${baseDir}/results/e_coli.fasta" 
    
    // Eğer o dosya yoksa, scripts içindeki veya başka bir yerdeki fasta yolunu yazabilirsin.
    
    // Kanalı oluşturuyoruz
    fasta_kanali = Channel.fromPath(test_fasta, checkIfExists: true)

    // --- AKIŞI BAŞLAT ---
    // Fasta dosyasını Workflow'a gönderiyoruz
    ANNOTATION_FLOW(fasta_kanali)
}
