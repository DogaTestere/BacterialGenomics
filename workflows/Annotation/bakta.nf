nextflow.enable.dsl = 2

// 1. Modülleri (Process'leri) çağırıyoruz
include { RUN_BAKTA } from '../../modules/Annotation/bakta.nf'
include { BAKTA_DB_DOWNLOAD } from "../../modules/Annotation/bakta_db.nf"

workflow BAKTA_FLOW {
    take:
    assembly_input  // Main'den gelen [id, fasta] ikilisi

    main:
    // Veritabanı yolunu belirliyoruz (Parametreden veya sabit yoldan)
    // Eğer params.bakta_db tanımlı değilse varsayılan db/db-light'a bakar
    //db_path = params.bakta_db ? file(params.bakta_db) : file("${projectDir}/db/db-light")
    db_path = BAKTA_DB_DOWNLOAD()

    // İşçiye (Process'e) malzemeyi veriyoruz
    (bakta_dir, bakta_gff, bakta_gbk, bakta_txt) = RUN_BAKTA(assembly_input, db_path)

    emit:
    // Çıktıları dışarı (Main'e) geri yolluyoruz
    bakta_dir
    bakta_gff
    bakta_gbk
    bakta_txt
}
