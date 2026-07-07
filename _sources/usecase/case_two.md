# Use case II: Fusion genes detection from **multiple myeloma patient** RNA-seq
## Background
RNA sequencing (RNA-seq) is widely used in clinical and translational research to profile gene expression, splicing patterns, fusion transcripts, and other transcriptional abnormalities. In diagnostic settings, common applications include:

1. ​​Cancer Subtyping​​: Identifying tumor-specific gene expression signatures, fusion genes (e.g., BCR-ABL1), and aberrant splicing events to guide targeted therapies.
2. Rare Disease Diagnosis​​: Detecting dysregulated pathways and aberrant expression in Mendelian disorders where DNA-based tests are inconclusive.
3. ​Infectious Disease Characterization​​: Profiling host-pathogen interactions and pathogen expression in complex infections.
4. Biomarker Discovery​​: Validating expression-based biomarkers for disease monitoring and treatment response.

Gene fusions are a major class of oncogenic alterations. They can generate chimeric transcripts, such as BCR::ABL1, or drive overexpression of partner oncogenes, such as IGH::CCND1. The ClinDet RNA workflow supports transcript quantification, fusion detection, immune repertoire analysis, and RNA variant calling. In this example, we reanalyze transcriptomic data from 31 flow-sorted bone marrow plasma cell samples published by [Jaime et al](https://www.nature.com/articles/s41467-021-25704-2). We focus on three multiple myeloma patients, CD1, MS3, and MF1, all reported to harbor rearrangements involving the IGH enhancer and partner genes.

```{image} ./jaime.png
:alt: BCR MM
:class: bg-primary
:width: 600px
:align: center
```

## Why this case matters
This case shows how the RNA workflow can be used to combine transcript quantification, fusion detection, and immune repertoire analysis in a clinically relevant hematologic malignancy setting. It is also a useful example of how RNA-seq can reveal both structural events and downstream transcriptional consequences.


## Setup a project folder
````{note}
Before starting the analysis, please ensure that you have set up the analysis environment using the build_conda_env.sh script.
````

Create a folder named `project/MM_RNA` in your home directory and activate the clindet conda environment.

```{code} bash
mkdir -p ~/projects/MM_RNA
cd ~/projects/MM_RNA
conda activate clindet
```
## Download data and setup a samplesheet.csv

Download Multiple myeloma RNA-seq data from the SRA database using wget and prepare the sample information file, make sure fastq-dump are in in $PATH (if don't install it first)

```{code} bash
cd ~/projects/MM_RNA
mkdir -p data && cd data
## Methods one multiple myeloma RNA-seq data
wget -q -c -O A26.11 https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR12099713/SRR12099713
wget -q -c -O A27.19 https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR12099714/SRR12099714
wget -q -c -O A28.15 https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR12099715/SRR12099715

fastq-dump --gzip -O ~/projects/MM_RNA/data --split-3 ./A26.11
fastq-dump --gzip -O ~/projects/MM_RNA/data --split-3 ./A27.19
fastq-dump --gzip -O ~/projects/MM_RNA/data --split-3 ./A28.15

```

Next, create a CSV file named pipe_rna.csv in the ~/projects/MM_RNA directory with the following content:

```
R1_file_path,R2_file_path,Sample_name,Project
~/projects/MM_RNA/data/A26.11_1.fastq.gz,~/projects/MM_RNA/data/A26.11_2.fastq.gz,MF1
~/projects/MM_RNA/data/A27.19_1.fastq.gz,~/projects/MM_RNA/data/A27.19_2.fastq.gz,MS3
~/projects/MM_RNA/data/A28.15_1.fastq.gz,~/projects/MM_RNA/data/A28.15_2.fastq.gz,CD1
```

## Prepare the YAML workflow config
In the current workflow, you no longer need to create a project-specific `snake_rna.smk` file. Instead, prepare a YAML configuration file and pass it to Snakemake with `--configfile`.

For this example, create `~/projects/MM_RNA/MM_RNA.yaml` and update the following fields:

1. `project.output_dir`: output directory for this analysis.
2. `project.genome_version`: reference genome version, such as `b37`.
3. `project.recal_BQSR`: whether to run BQSR.
4. `project.vcf2maf`: VCF-to-MAF mode.
5. `project.sample_sheet`: absolute path to the RNA sample sheet CSV file.
6. `run_params.stages`: RNA analysis stages to run.
7. `run_params.rna_caller_list`: RNA caller preset used for this analysis.

:::{note}
```{code} yaml
project:
  output_dir: '~/projects/MM_RNA'
  genome_version: 'b37'
  recal_BQSR: False
  vcf2maf: 'raw'
  sample_sheet: '~/projects/MM_RNA/pipe_rna.csv'
run_params:
  stages:
    - salmon
    - RSEM
    - kallisto
    - arriba
    - trust4
  rna_caller_list:
    - default
```
:::

## Configuration rationale
This configuration is designed for an RNA-seq case where both expression quantification and biologically interpretable structural readouts are important. The selected stages retain three quantification methods, `salmon`, `RSEM`, and `kallisto`, while also enabling `arriba` for fusion detection and `trust4` for immune repertoire analysis. The `default` RNA caller preset is used here as a balanced starting point for a general multiple myeloma RNA workflow.

## Run ClinDet 
There is two way you can run ClinDet
1. run on a local server 
2. submit to HPC through slurm

### Run on local node 
```{code} bash
nohup snakemake -c 20 --config run_type=rna \
--configfile ~/projects/MM_RNA/MM_RNA.yaml \
--rerun-triggers mtime --benchmark-extended \
--use-singularity --singularity-args "--bind /your/home/path:/your/home/path" \
--latency-wait 300 --use-conda --conda-frontend conda -k >> ~/projects/MM_RNA/MM_RNA.out &
```

### Submit to HPC use slurm
We provide a Slurm `config.yaml` file under the `clindet/workflow/config_slurm` folder.
```{code}  bash
nohup snakemake -c 20 --config run_type=rna \
--configfile ~/projects/MM_RNA/MM_RNA.yaml \
--profile workflow/config_slurm \
--rerun-triggers mtime --benchmark-extended \
--use-singularity --singularity-args "--bind /your/home/path:/your/home/path" \
--latency-wait 300 --use-conda --conda-frontend conda -k >> ~/projects/MM_RNA/MM_RNA.out &
```

## Results
After successful execution, you will see the following directory structure. The fusion folder contains the fusion gene detection results, and the summary folder contains the gene expression quantification results.

### Overview of outputs
```bash
~/projects/MM_RNA/b37/results
├── fusion # Fusion Gene Detection Results
├── mapped # STAR mapping results
│   └── STAR
├── mut # RNA Mutation Detection Results
│   ├── dedup
│   ├── maf # annotated MAF file
│   ├── STAR
│   └── vcf
├── IG # Immune repertoire reconstruction results
│   └── TRUST4
│ 
└── summary # Results of Gene Expression Quantification
    ├── kallisto
    ├── RSEM
    └── salmon
```

### What to expect
For this case, the most informative outputs are the `arriba` fusion calls, the expression quantification results in the `summary` directory, and the `TRUST4` immune repertoire outputs. Successful completion should allow readers to inspect whether IGH-associated rearrangements are detectable at the transcript level and whether partner-gene overexpression is consistent with the published biology.

## Common pitfalls
1. `sample_sheet` should be an absolute path and must point to files visible inside the Singularity bind mount.
2. `genome_version` in the YAML file must match the RNA reference resources configured in the global `config.yaml`.
3. If `arriba` is enabled, the alignment and fusion resources must be available for the selected reference build.
4. If `trust4` is enabled, users should expect additional runtime and should verify that the resulting immune repertoire files are produced before interpreting clonality.

### arriba fusion genes
Within the gene fusion detection analysis, structural variants were identified in patients CD1 (IGH::CCND1) and MS3 (IGH::NSD2). In contrast, no detectable fusion transcript was found in patient MF1. However, all three patients exhibited aberrantly high expression levels of the corresponding partner genes. We hypothesize that the structural variation breakpoint in the IGH locus of patient MF1 may reside upstream of the MAF gene, possibly in a non-coding regulatory region, allowing enhancer-driven overexpression without producing a fusion transcript.
***IGH*** fusion genes circos plot (see below):

```{image} ../img/usecase/usecase_two/arriba_fusion.png
:alt: fusion circos 
:class: bg-primary
:width: 900px
:align: left
```

### Aberrant expression of partner genes 
Additionally, if you wish to study gene expression levels, you can download the data for all samples from the original publication and perform quantification. Subsequently, use the Outliner package to analyze genes with aberrant expression within the patient cohort. In this example, we will not include this analysis, but interested readers are encouraged to download the data and explore it on their own, The figure below shows the expected analysis results.

```{image} ../img/usecase/usecase_two/expression.png
:alt: fusion expression 
:class: bg-primary
:width: 900px
:align: left
```

### immune repertoire analysis
Furthermore, immune repertoire profiling of the three samples revealed that more than 95% of the immunoglobulin sequences originated from a single clone. This finding is consistent with the prevailing hypothesis that multiple myeloma arises from a clonal expansion of a single progenitor B cell.


```{image} ./BCR.png
:alt: BCR MM
:class: bg-primary
:width: 300px
:align: center
```
