#!/bin/bash -ue
mkdir -p bam
samtools view -uS -o bam/GCA_000008865.2_ASM886v2_genomic.bam GCA_000008865.2_ASM886v2_genomic.sam
samtools sort -@ 4 -T GCA_000008865.2_ASM886v2_genomic.tmp.sort -o GCA_000008865.2_ASM886v2_genomic_sorted.bam bam/GCA_000008865.2_ASM886v2_genomic.bam
