# Use case I: SNV and CNV calling from Whole exome sequencing data

## Background
## Download data
## Download and confing  C.elegans genome file

## write Snakemake file 
For this project, we need change the  sample sheet info.
:::{tip}
:class: dropdown

```{code} python

import pandas as pd
samples_info = pd.read_csv('',index_col='Sample_name') # set sample sheet path

unpaired_samples = samples_info.loc[pd.isna(samples_info['Normal_R1_file_path'])].index.tolist()
paired_samples = samples_info.loc[~pd.isna(samples_info['Normal_R1_file_path'])].index.tolist()

configfile: "" # set config file path

project = samples_info["Project"].unique().tolist()[0]
genome_version = 'WBcel235' # set genome version 

import os
if not os.path.exists("logs/slurm"):
    os.makedirs("logs/slurm")

pre_pon_db = False

if not os.path.exists('analysis/pindel_normal/log'):
    os.makedirs('analysis/pindel_normal/log')

groups = ['NC','T']

germ_caller_list = ['caveman']
caller_list = ['strelkasomaticmanta','caveman','muse','cgppindel_filter']

recall_pon =  False
recall_pon_pindel =  False

recal = False
rule all:
    input:
        ## paired sample
        expand([
            "{project}/{genome_version}/results/dedup/paired/{sample}-{group}.sorted.bam",
            "{project}/{genome_version}/results/sv/paired/DELLY/{sample}/SV_delly_{sample}_filter.vcf",
            "{project}/{genome_version}/results/vcf/paired/{sample}/strelkasomaticmanta.vcf",
            "{project}/{genome_version}/results/vcf/paired/{sample}/muse.vcf",
            '{project}/{genome_version}/logs/paired/caveman_{sample}.log',
        ],
        project = project,
        genome_version = genome_version,
        sample = paired_samples,
	    group = groups,
        caller = caller_list)

include: "workflow/WGS/Snakefile"  # the relative path of clindet workflow WGS subfolder snakefile  


```
:::

## Run clindet 

``` bash
nohup snakemake --profile workflow/config_slurm \
-j 30 --printshellcmds -s snake_wgs_worm.smk \
--use-singularity \
--singularity-args "--bind /public/home/:/public/home/,/public/ClinicalExam:/public/ClinicalExam" \
--latency-wait 300 --use-conda -