#!/bin/bash -ue
mkdir -p bam
samtools view -uS -o bam/ec1_S1_L001.bam ec1_S1_L001.sam
samtools sort -@ 4 -T ec1_S1_L001.tmp.sort -o ec1_S1_L001_sorted.bam bam/ec1_S1_L001.bam
