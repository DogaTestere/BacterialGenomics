process BCFTOOLS_CALL {
    input:
    path ref_file
    path sorted_bam
    path indexed_bam

    output:
    path bcf_file

    script:
    bcf_file = "${sorted_bam.baseName}.bcf"
    "bcftools mpileup -f $ref_file $sorted_bam | bcftools call -mv -Ob -o $bcf_file"
}

/*
referans genom ve bam dosyası ile mutayonların veya farklı genotiplerin olasığını hesaplıyor, sonrasında oluşan bcf dosyasını döndürüyor

Burada olasılık hesaplanırken referans genomdaki konumlar ve bam dosyasındaki kalite değerleri kullanılıyor.
Bunun sayesinde SNP'ler veya InDel mutasyonları görülebilir veya farklı genotipler görülebilir.

Index dosyasını verirsek hata oluşuyor, sadece .bam dosyasını kullanıyor
"[E::hts_open_format] Failed to open file "ec1_S1_L001_sorted.bam.bai" : Exec format error"

İndex dosyasının yanda aksuar olarak verilmesi lazım
*/