nextflow.enable.dsl=2

workflow {
    // 1. Örnek DNA Verisi (ID ve DNA dizisi)
    def dna_samples = [
        [id: 'S1', seq: 'ATGCGT'], 
        [id: 'S2', seq: 'ATGCGTATGC'], // Uzun
        [id: 'S3', seq: 'ATGCGT'],     // S1 ile aynı (Duplicate)
        [id: 'S4', seq: 'ATG'],        // Kısa
        [id: 'S5', seq: 'ATGCGTATGCGTATGC'], // En Uzun
        [id: 'S6', seq: 'GCTAGCT']
    ]

    channel.fromList(dna_samples)

        // 1. UNIQUE: Aynı DNA dizisine sahip mükerrer kayıtları siler.
        // S1 ve S3 aynı diziye sahip, biri elenir.
        .unique { it.seq }

        // 2. SORT: Dizileri karakter uzunluğuna göre büyükten küçüğe sıralar.
        .toSortedList({ a, b -> b.seq.length() <=> a.seq.length() })

        // 3. TAKE (Limit): En uzun olan ilk 3 DNA dizisini alır.
        .flatMap()
        .take(3)

        // Ekrana bas
        .view { "Biyolojik Sonuç -> ID: ${it.id} | Dizi Uzunluğu: ${it.seq.length()} | Dizi: ${it.seq}" }
}
