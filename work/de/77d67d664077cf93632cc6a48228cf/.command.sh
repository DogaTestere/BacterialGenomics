#!/bin/bash -ue
mkdir -p ref_index
bowtie2-build --threads 4 GCA_000008865.2_ASM886v2_genomic.fna ref_index/GCA_000008865.2_ASM886v2_genomic
