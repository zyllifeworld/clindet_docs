# Clinical Omics Benchmark Datasets

```{image} ./clindet_gym.png
:alt: glioma
:class: bg-primary
:width: 600px
:align: center
```

To systematically evaluate the performance of computational tools for clinical molecular diagnostics, we propose to construct a comprehensive gold-standard benchmarking dataset by integrating multiple high-quality public cancer genomics resources. As illustrated in the figure, diverse datasets—including TCGA, CCLE, COLO829, ICGC, CPTAC, HCMI, CGIB, and GIAB—serve as foundational “training equipment,” collectively supporting the development and validation of robust analytical workflows.

These datasets encompass a wide range of sequencing modalities (WES, WGS, and RNA-seq) and variant types, including single nucleotide variants (SNVs), insertions and deletions (Indels), structural variants (SVs), copy number variations (CNVs), and gene fusions. By leveraging their complementary characteristics—such as tumor-normal paired samples, deeply characterized cell lines, and high-confidence reference genomes—we aim to curate a harmonized dataset with well-defined ground truth annotations.

A standardized quality control and data processing pipeline will be applied to ensure consistency across datasets, including alignment, variant calling, filtering, and orthogonal validation where applicable. The resulting benchmark dataset will enable systematic evaluation of tool performance in terms of sensitivity, specificity, precision, and robustness across diverse genomic contexts.

Ultimately, this resource is intended to serve as a community reference for benchmarking clinical genomics tools, facilitating fair comparison between methods and promoting the development of more accurate and reliable computational approaches for precision oncology applications.
This document collects publicly available datasets for benchmarking NGS-based tumor detection tools.


```{image} ./qc_dataset.png
:alt: glioma
:class: bg-primary
:width: 600px
:align: center
```



### Supported sequencing types
- Whole Exome Sequencing (WES)
- Whole Genome Sequencing (WGS)
- RNA Sequencing (RNA-seq)

### Supported variant types
- SNV / Indel
- Structural Variants (SV)
- Copy Number Variations (CNV)
- Gene Fusions

---

## Dataset Summary

| Dataset Name | Data Type | Variant Type | Sample Type | Ground Truth | Access | Notes |
|-------------|----------|-------------|-------------|-------------|--------|------|
| [TCGA](#the-cancer-genome-atlas) | WES/WGS/RNA | SNV, CNV, Fusion | Tumor | Partial | Controlled | Large cohort |
| [ICGC](#international-cancer-genome-consortium) | WGS/WES | SNV, SV, CNV | Tumor | Yes | Controlled | International |
| GIAB | WGS | SNV, Indel | Germline | High-confidence | Open | Gold standard |
| CGIB | WGS,WES,long-read, | SNV, Indel | Somatic | High-confidence | Open | Gold standard |
| SEQC2 | WES/WGS | SNV, CNV | Synthetic | Yes | Open | Benchmark focused |
| PCAWG | WGS | SNV, SV, CNV | Tumor | Yes | Controlled | Deep annotation |
| CCLE | WES/RNA | SNV, CNV, Fusion | Cell line | Partial | Open | Cancer cell lines |
| CCLE | WES/RNA | SNV, CNV, Fusion | Cell line | Partial | Open | Cancer cell lines |

---

## Dataset Details


### The Cancer Genome Atlas

- Website: https://portal.gdc.cancer.gov/
- Data Type: WES, WGS (limited), RNA-seq
- Variant Types: SNV, Indel, CNV, Fusion
- Sample Type: Tumor / Normal pairs
- Ground Truth: Partial (validated subsets)

#### Access
- Open + controlled (dbGaP required)
- GDC Data Portal / API

#### Recommended Usage
- SNV/Indel benchmarking
- RNA fusion detection
- CNV analysis

#### Notes
- Not a strict ground truth dataset
- Requires harmonization

---

### International Cancer Genome Consortium

- Website: https://dcc.icgc.org/
- Data Type: WGS, WES
- Variant Types: SNV, SV, CNV
- Sample Type: Tumor
- Ground Truth: Curated calls

#### Access
- Controlled access (DACO approval)

#### Recommended Usage
- Structural variant benchmarking
- Cross-cohort validation

---

(GIAB)=
### GIAB (Genome in a Bottle)

- Website: https://www.nist.gov/programs-projects/genome-bottle
- Data Type: WGS
- Variant Types: SNV, Indel
- Sample Type: Germline reference
- Ground Truth: High-confidence regions

#### Download
- https://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/

#### Recommended Usage
- SNV/Indel caller benchmarking
- Precision/recall evaluation

#### Notes
- Not tumor data
- Limited SV/CNV truth sets

---

(SEQC2)=
### SEQC2 (MAQC Consortium)

- Website: https://www.fda.gov/science-research/bioinformatics-tools/seqc2
- Data Type: WES, WGS
- Variant Types: SNV, CNV
- Sample Type: Synthetic / reference mixtures
- Ground Truth: Known spike-ins

#### Download
- https://www.ncbi.nlm.nih.gov/sra

#### Recommended Usage
- Sensitivity benchmarking
- Low VAF detection

---

### PCAWG (Pan-Cancer Analysis of Whole Genomes)

- Website: https://dcc.icgc.org/pcawg
- Data Type: WGS
- Variant Types: SNV, SV, CNV
- Sample Type: Tumor / Normal
- Ground Truth: Consensus calls

#### Access
- Controlled access (ICGC portal)

#### Recommended Usage
- SV detection benchmarking
- Pan-cancer analysis

---

### CCLE (Cancer Cell Line Encyclopedia)

- Website: https://depmap.org/portal/
- Data Type: WES, RNA-seq
- Variant Types: SNV, CNV, Fusion
- Sample Type: Cell lines
- Ground Truth: Partial

#### Download
- Open access via DepMap

#### Recommended Usage
- Fusion detection
- CNV benchmarking
- Reproducibility testing

---

## Specialized Benchmark Datasets

### DREAM Challenge Datasets

- Website: https://www.synapse.org/
- Focus: Somatic mutation calling
- Ground Truth: Simulated + validated

---

### Synthetic Datasets

| Dataset | Description | Link |
|--------|------------|------|
| BAMSurgeon | Spike-in mutations | https://github.com/adamewing/bamsurgeon |
| VarSim | Variant simulation | https://github.com/bioinform/varsim |

---

## Metadata Schema

Each dataset entry should follow the schema below:

```yaml
Dataset Name:
Data Type:
Variant Type:
Sequencing Platform:
Read Length:
Coverage:
Sample Size:
Tumor Type:
Matched Normal:
Ground Truth Type:
Download Link:
Access Type:
License:
Contact:
Last Updated:
Contributor:
Validation Status:
Benchmark Category: