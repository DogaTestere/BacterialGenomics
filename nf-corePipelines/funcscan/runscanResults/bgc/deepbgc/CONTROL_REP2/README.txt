DeepBGC
================================================================================
/usr/local/bin/deepbgc pipeline --score 0.5 --prodigal-meta-mode --merge-max-protein-gap 0 --merge-max-nucl-gap 0 --min-nucl 1 --min-proteins 1 --min-domains 1 --min-bio-domains 0 --classifier-score 0.5 CONTROL_REP2_pyrodigal.gbk
================================================================================
LOG.txt	Log output of DeepBGC
CONTROL_REP2_pyrodigal.antismash.json 	AntiSMASH JSON file for sideloading.
CONTROL_REP2_pyrodigal.bgc.gbk 	Sequences and features of all detected BGCs in GenBank format
CONTROL_REP2_pyrodigal.bgc.tsv 	Table of detected BGCs and their properties
CONTROL_REP2_pyrodigal.full.gbk 	Fully annotated input sequence with proteins, Pfam domains (PFAM_domain features) and BGCs (cluster features)
CONTROL_REP2_pyrodigal.pfam.tsv 	Table of Pfam domains (pfam_id) from given sequence (sequence_id) in genomic order, with BGC detection scores
evaluation/CONTROL_REP2_pyrodigal.bgc.png 	Detected BGCs plotted by their nucleotide coordinates
evaluation/CONTROL_REP2_pyrodigal.pr.png 	Precision-Recall curve based on predicted per-Pfam BGC scores
evaluation/CONTROL_REP2_pyrodigal.roc.png 	ROC curve based on predicted per-Pfam BGC scores
evaluation/CONTROL_REP2_pyrodigal.score.png 	BGC detection scores of each Pfam domain in genomic order

