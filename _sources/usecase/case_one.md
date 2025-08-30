# Use case I: SNV and CNV calling from Whole exome sequencing data

## Background
Whole Exome Sequencing (WES) is a powerful tool in clinical diagnostics, enabling the comprehensive analysis of protein-coding regions (~1-2% of the genome) to identify disease-causing variants. Key applications include:

1. ​​Rare Disease Diagnosis​​: Rapid detection of pathogenic variants in undiagnosed genetic disorders, reducing diagnostic odysseys.
2. ​​Cancer Genomics​​: Profiling somatic and germline mutations to guide targeted therapy and risk assessment.
​​3. Carrier Screening​​: Identifying recessive mutations in prospective parents for reproductive planning.
​​Pharmacogenomics​​: Assessing drug-response variants to optimize treatment regimens.
4. WES improves diagnostic yield (~30-40% for rare diseases) while maintaining cost-efficiency compared to whole-genome sequencing. Integration with ACMG/AMP guidelines ensures clinically actionable reporting.

The Clindet WES analysis pipeline supports the analysis of Whole Exome Sequencing (WES), panel, and targeted sequencing data, allowing each sample to correspond to different target regions. This workflow performs both somatic and germline variant calling from WES data and supports analyses of paired tumor-normal samples as well as tumor-only samples. It integrates multiple variant callers to detect single nucleotide variants (SNVs), insertions and deletions (INDELs), copy number variations (CNVs), and structural variations (SVs), followed by comprehensive quality control and reporting.


In this example, we will use Clindet to analyze several whole exome sequencing samples from the publicly available Chinese Glioma Genome Atlas (CGGA) dataset. The sequencing data will be aligned to the b37 version of the human reference genome, followed by detection of somatic mutations and copy number variations.

## Setup a project folder
````{note}
Before starting the analysis, please ensure that you have set up the analysis environment using the build_conda_env.sh script.
````

Create a folder named project/CGGA_WES in your home directory and activate the Clindet conda environment.

```{code} bash
mkdir -p ~/projects/CGGA_WES
cd ~/projects/CGGA_WES
conda activate clindet
```
## Download data and 

Download data from the GSA database using wget and prepare the sample information file.

```{code} bash
cd ~/projects/CGGA_WES
mkdir -p data && cd data
## sample CGGA_D14 tumor-sample paired fqs
wget -c -O T_CGGA_D14_r1.fq.gz ftp://download.big.ac.cn/gsa-human/HRA000071/HRR025119/HRR025119_f1.fq.gz
wget -c -O T_CGGA_D14_r2.fq.gz ftp://download.big.ac.cn/gsa-human/HRA000071/HRR025119/HRR025119_r2.fq.gz
wget -c -O B_CGGA_D14_r1.fq.gz ftp://download.big.ac.cn/gsa-human/HRA000071/HRR024833/HRR024833_f1.fq.gz
wget -c -O B_CGGA_D14_r2.fq.gz ftp://download.big.ac.cn/gsa-human/HRA000071/HRR024833/HRR024833_f2.fq.gz

## sample CGGA_653 tumor-sample paired fqs
wget -c -O T_CGGA_653_r1.fq.gz	ftp://download.big.ac.cn/gsa-human/HRA000071/HRR025103/HRR025103_f1.fq.gz	wget -c -O T_CGGA_653_r2.fq.gz  ftp://download.big.ac.cn/gsa-human/HRA000071/HRR025103/HRR025103_r2.fq.gz
wget -c -O B_CGGA_653_r1.fq.gz	ftp://download.big.ac.cn/gsa-human/HRA000071/HRR024817/HRR024817_f1.fq.gz
wget -c -O B_CGGA_653_r2.fq.gz	ftp://download.big.ac.cn/gsa-human/HRA000071/HRR024817/HRR024817_r2.fq.gz
```

Next, create a CSV file named pipe_wes.csv in the ~/projects/CGGA_WES directory with the following content:

```
Tumor_R1_file_path,Tumor_R2_file_path,Normal_R1_file_path,Normal_R2_file_path,Sample_name,Target_file_bed,Project
~/projects/CGGA_WES/data/T_CGGA_D14_r1.fq.gz,~/projects/CGGA_WES/data/T_CGGA_D14_r2.fq.gz,~/projects/CGGA_WES/data/B_CGGA_D14_r1.fq.gz,~/projects/CGGA_WES/data/B_CGGA_D14_r1.fq.gz,CGGA_D14,target.bed,CGGA_WES
~/projects/CGGA_WES/data/T_CGGA_653_r1.fq.gz,~/projects/CGGA_WES/data/T_CGGA_653_r2.fq.gz,~/projects/CGGA_WES/data/B_CGGA_653_r1.fq.gz,~/projects/CGGA_WES/data/B_CGGA_653_r1.fq.gz,CGGA_653,target.bed,CGGA_WES
```

## Write an Snakemake file from template 
For this project, modify the sample sheet and create a new Snakemake file named **snake_wes.smk** (see below). Set the following parameters in the Snakemake file:

1. **configfile (str)**: config file for softwares and resource parameters.
1. **stage (list)**: analysis steps. avaiable options:`['conpair','report']`
2. **sample_csv (str)**: `sample_info.csv` path
3. **genome_version (str)**: genome version, can be genome version which setup in cofig.yaml eg. `b37`
4. **recal (Boolean)**: use GATK BaseRecalibrator for Base Quality Score Recalibration?  this is a time-consume task   but can slightly improved calling accuracy. `True or False`. default `True`.
5. **caller_list (list)**: somatic mutation calling softwares used. avaiable options:`['sage','HaplotypeCaller','strelkasomaticmanta','cgppindel_filter','caveman','muse','deepvariant','Mutect2_filter'] `
6. **germ_call_list (list)**: germline mutation calling softwares used. avaiable options: `['strelkamanta','caveman']`
7. **somatic_cnv_list (list)**: Somatic Copy Number variant calling softwares. avaiable options: `['purple','ASCAT','sequenza','freec','exomedepth']`
8. **recall_pon (Boolean)**: call panel-of-normal mutect2_pon.vcf from cohort normal samples. default `False`, use public available resource.
9. **custome_pon_db (Boolean)**: use public available resource. default `False`.
10. **recall_pon_pindel (Boolean)**: call panel-of-normal pindel_pon.vcf from cohort normal samples. default `False`, use public available resource.

:::{note}
```{code} python
import pandas as pd
sample_csv = '~/projects/CGGA_WES/pipe_WES.csv'
samples_info = pd.read_csv(sample_csv,index_col='Sample_name')
unpaired_samples = samples_info.loc[pd.isna(samples_info['Normal_R1_file_path'])].index.tolist()
paired_samples = samples_info.loc[~pd.isna(samples_info['Normal_R1_file_path'])].index.tolist()

configfile: "/AbsoPath/of/clindet/folder/config/config.yaml"

project = samples_info["Project"].unique().tolist()[0]
genome_version = 'b37'
recal = False
pre_pon_db = False

groups = ['NC','T']
## somatic mutation calling softwares
caller_list = ['sage','HaplotypeCaller','strelkasomaticmanta','cgppindel_filter','caveman','muse','deepvariant','Mutect2_filter']
stages = ['report','conpair']
# germline mutation calling softwares
germ_caller_list = ['strelkamanta','caveman']
# somatic CNV calling softwares
somatic_cnv_list = ['purple','ASCAT','facets','sequenza','freec']
# tumor-only somatic mutation calling softwares
tumor_only_caller = ['sage']

recall_pon =  False
custome_pon_db = True
recall_pon_pindel =  False

## paired sample list
paired_res_list = [
    ##### for QC report ######
    # rules.conpair_contamination.output           if 'conpair'          in stages else None,
    '{project}/{genome_version}/logs/paired/conpair/{sample}.done' if 'conpair'          in stages else None,
    ##### for SNV/INDEL calling #####
    "{project}/{genome_version}/results/maf/paired/{sample}/merge/{sample}.maf",
    ##### for CNV result ##### There is a bug for snakemake rules namelist when include *smk for 3-4 levels
    # rules.paired_purple.output.qc  if 'purple' in somatic_cnv_list else None, # purple call
    "{project}/{genome_version}/results/cnv/paired/purple/{sample}/purple/{sample}.purple.qc"  if 'purple' in somatic_cnv_list else None, # purple call
    # rules.CNA_ASCAT.output.rdata   if 'ASCAT'  in somatic_cnv_list else None, # ASCAT call
    "{project}/{genome_version}/results/cnv/paired/ascat/{sample}/{sample}_ASCAT.rdata"   if 'ASCAT'  in somatic_cnv_list else None, # ASCAT call
    # rules.facets.output.qc         if 'facets' in somatic_cnv_list else None, # facets call
    # rules.facets.output.qc         if 'facets' in somatic_cnv_list else None, # facets call
    "{project}/{genome_version}/results/cnv/paired/freec/{sample}/{sample}_config_freec.ini" if 'freec' in somatic_cnv_list else None, # Control-FREEC call
    # rules.CNA_exomedepth.output.tsv       if 'exomedepth' in somatic_cnv_list else None, # sequenza call
    "{project}/{genome_version}/results/cnv/paired/exomedepth/{sample}/{sample}_exomedepth.tsv"  if 'exomedepth' in somatic_cnv_list else None, # sequenza call
    # rules.sequenza_call.output.segment       if 'sequenza' in somatic_cnv_list else None, # sequenza call
    # "{project}/{genome_version}/results/cnv/paired/sequenza/{sample}/{sample}_segments.txt"  if 'sequenza' in somatic_cnv_list else None, # sequenza call
    #### Case report #####
]
paired_res_list = list(filter(None, paired_res_list))
##### Modules #####
rule all:
    input:
        ## paired sample
        expand(paired_res_list,
        sample = paired_samples,
        project = project,
        genome_version = genome_version,
        group = groups,
        caller = caller_list),
        #### unpaired sample
        expand([
            "{project}/{genome_version}/results/recal/unpaired/{sample}-T.bam",
            "{project}/{genome_version}/results/maf/unpaired/{sample}/merge/{sample}.maf",
            "{project}/{genome_version}/results/maf/unpaired/{sample}/{caller}.vcf.maf"
        ],
        project = project,
        genome_version = genome_version,
        sample = unpaired_samples,
        caller = tumor_only_caller),
        ##### multiqc report ########
        f'{project}/{genome_version}/results/multiqc/filelist.txt',
        f'{project}/{genome_version}/results/multiqc_report.html'


include: '/AbsoPath/of/clindet/folder/workflow/WES/Snakefile'  # the absolutely path of clindet workflow WGS subfolder snakefile  
```
:::


## Run clindet 
There is two way you can run clindet
1. run on a local server 
2. submit to HPC through slurm

### Run on local node 
```{code} bash
nohup snakemake -j 30 --printshellcmds -s snake_wes.smk \
--use-singularity --singularity-args "--bind /public/home/:/public/home/,/public/ClinicalExam:/public/ClinicalExam" \
--latency-wait 300 --use-conda >> wes.log
```

### Submit to HPC use slurm
we provide a slurm config.yaml under clindet/workflow/config_slurm folder.
```{code}  bash
nohup snakemake --profile workflow/config_slurm \
-j 30 --printshellcmds -s snake_wes.smk --use-singularity \
--singularity-args "--bind /public/home/:/public/home/,/public/ClinicalExam:/public/ClinicalExam" \
--latency-wait 300 --use-conda >> wes.log
```

### Output

### case report
There is a example case report of CGGA_P438
<a href="../_static/CGGA_P438_cancer_report.html">example report HTML</a>