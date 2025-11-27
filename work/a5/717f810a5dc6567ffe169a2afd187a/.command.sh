#!/bin/bash -ue
bcftools mpileup -f GCA_000008865.2_ASM886v2_genomic.fna ec1_S1_L001_sorted.bam | bcftools call -mv -Ob -o GCA_000008865.2_ASM886v2_genomic.bcf
