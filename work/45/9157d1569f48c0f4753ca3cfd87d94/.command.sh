#!/bin/bash -ue
bcftools convert -O v -o GCA_000008865.2_ASM886v2_genomic.vcf GCA_000008865.2_ASM886v2_genomic.bcf
bgzip -c GCA_000008865.2_ASM886v2_genomic.vcf > GCA_000008865.2_ASM886v2_genomic.vcf.gz
tabix -p vcf GCA_000008865.2_ASM886v2_genomic.vcf.gz
