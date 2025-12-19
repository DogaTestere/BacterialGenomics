process BCFTOOLS_INDEX {
    input:
    path bcf_file

    output:
    tuple path(zipped_file), path(indexed_vcf), path(vcf_file)

    script:
    vcf_file = "${bcf_file.baseName}.vcf"
    indexed_vcf = "${bcf_file.baseName}.vcf.gz.csi"
    zipped_file = "${bcf_file.baseName}.vcf.gz"
    """
    bcftools convert -O v -o $vcf_file $bcf_file
    bcftools view -Oz -o $zipped_file $bcf_file
    bcftools index $zipped_file
    """
}
/*
bcf dosyasını vcf dosyasına dönüştürüyor sonrasında sıkıştırıp, indeksliyor
Sonrasında hem sıkıştırılmış dosya ve indeksli dosya geri gönderiliyor çünkü concencus oluşumunda iki dosyaya da ihtiyaç var
Yoksa "[E::idx_find_and_load] Could not retrieve index file for 'GCA_000008865.2_ASM886v2_genomic.vcf.gz'" hatası veriyor
*/