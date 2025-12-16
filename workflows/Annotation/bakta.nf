nextflow.enable.dsl = 2

// 1. Modülleri (Process'leri) çağırıyoruz
include { RUN_BAKTA } from './bakta.nf'

workflow BAKTA_FLOW {
    take:
    assembly_input  // Main'den gelen [id, fasta] ikilisi

    main:
    // Veritabanı yolunu belirliyoruz (Parametreden veya sabit yoldan)
    // Eğer params.bakta_db tanımlı değilse varsayılan db/db-light'a bakar
    db_path = params.bakta_db ? file(params.bakta_db) : file("${projectDir}/db/db-light")

    // İşçiye (Process'e) malzemeyi veriyoruz
    bakta_results = RUN_BAKTA(assembly_input, db_path)

    emit:
    // Çıktıları dışarı (Main'e) geri yolluyoruz
    bakta_out_dir = bakta_results.bakta_dir
    bakta_gff     = bakta_results.bakta_gff
}
