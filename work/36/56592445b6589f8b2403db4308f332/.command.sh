#!/bin/bash -ue
bowtie2 -x ref_index/GCA_000008865.2_ASM886v2_genomic -1 ec1_S1_L001_R1_001.fastq.gz -2 ec1_S1_L001_R2_001.fastq.gz -S GCA_000008865.2_ASM886v2_genomic.sam
