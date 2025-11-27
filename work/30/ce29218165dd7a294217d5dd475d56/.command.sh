#!/bin/bash -ue
bcftools mpileup -f GCA_000008865.2_ASM886v2_genomic.fna GCA_000008865.2_ASM886v2_genomic_sorted.bam | bcftools call -mv -Ob -o GCA_000008865.2_ASM886v2_genomic.bcf
