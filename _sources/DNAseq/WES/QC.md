(wes)=
# WES
- [Whole exome sequence analysis workflow](#wes)
  - [QC](#qc)
    - [fastp](#fastp)
    - [Conpair](#conpair)
  - [SNPs and small indels (Germline)](#snps-and-small-indels-germline)
  - [Copy Number Variants](#copy-number-variants)


(qc)=
## QC


(fastp)=
### fastp
fastp is a tool designed to provide ultrafast all-in-one preprocessing and quality control for FastQ data.


(conpair)=
### Conpair
[Conpair](https://github.com/nygenome/conpair) is a fast and robust method dedicated for human tumor-normal studies to perform concordance verification (i.e. samples coming from the same individual), as well as cross-individual contamination level estimation in whole-genome and whole-exome sequencing experiments.


```{note}


```

(snps-and-small-indels-germline)=
## Reads mapping and PCR deduplication
Clindet use BWA to mapping short reads to genome,GATK was use to mark PCR duplicate reads for downstream analysis.
## Reads mapping statistics
GATK was used to calculate the reads  mapping percentage and coverage of each mapping BAM file.
## GATK preprocess
Firstly,read mapping quality was 
[def]: nv:sphinx:std#inde

(copy-number-variants)=
## copy-number-variants