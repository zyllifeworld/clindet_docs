# Available datasets for NGS tools Benchmark

## Overview

This document organizes benchmarking datasets by **data type and variant type**, rather than by individual dataset.

It is designed to help:
- Select appropriate datasets for specific tool benchmarking
- Standardize evaluation across different variant types
- Enable collaborative dataset curation

---

## Data Type Categories

- [WES - SNV / Indel](#wes---snv--indel)
- [WES - CNV](#wes---cnv)
- [WGS - SNV / Indel](#wgs---snv--indel)
- [WGS - Structural Variants (SV)](#wgs---structural-variants-sv)
- [WGS - CNV](#wgs---cnv)
- [RNA-seq - Gene Fusion](#rna-seq---gene-fusion)
- [RNA-seq - Expression / Variant](#rna-seq---expression--variant)
- [Synthetic / Spike-in Datasets](#synthetic--spike-in-datasets)

---

## WES - SNV / Indel

### Description
Datasets suitable for benchmarking somatic or germline SNV/Indel detection using WES.

### Recommended Datasets

| Dataset | Sample Type | Ground Truth | Access | Link |
|--------|------------|-------------|--------|------|
| TCGA | Tumor/Normal | Partial | Controlled | https://portal.gdc.cancer.gov/ |
| SEQC2 | Synthetic | Yes | Open | https://www.ncbi.nlm.nih.gov/sra |
| GIAB | Germline | High-confidence | Open | https://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/ |

### Benchmark Focus
- Sensitivity (low VAF)
- Precision / Recall
- Caller comparison (Mutect2, Strelka2, etc.)

---

## WES - CNV

### Description
Datasets for copy number variation detection using exome sequencing.

### Recommended Datasets

| Dataset | Sample Type | Ground Truth | Access | Link |
|--------|------------|-------------|--------|------|
| TCGA | Tumor | Partial | Controlled | https://portal.gdc.cancer.gov/ |
| CCLE | Cell line | Partial | Open | https://depmap.org/portal/ |

### Benchmark Focus
- Exon-level CNV detection
- Noise handling
- Tool comparison (CNVkit, EXCAVATOR, etc.)

---

## WGS - SNV / Indel

### Description
High-confidence SNV/Indel benchmarking using whole genome sequencing.

### Recommended Datasets

| Dataset | Sample Type | Ground Truth | Access | Link |
|--------|------------|-------------|--------|------|
| GIAB | Germline | High-confidence | Open | https://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/ |
| PCAWG | Tumor | Consensus | Controlled | https://dcc.icgc.org/pcawg |
| ICGC | Tumor | Curated | Controlled | https://dcc.icgc.org/ |

### Benchmark Focus
- Genome-wide accuracy
- Difficult regions (GC-rich, repeats)

---

## WGS - Structural Variants (SV)

### Description
Datasets for benchmarking structural variant detection.

### Recommended Datasets

| Dataset | Sample Type | Ground Truth | Access | Link |
|--------|------------|-------------|--------|------|
| PCAWG | Tumor | Consensus | Controlled | https://dcc.icgc.org/pcawg |
| ICGC | Tumor | Curated | Controlled | https://dcc.icgc.org/ |

### Benchmark Focus
- Large deletions / insertions
- Inversions / translocations
- Breakpoint resolution

---

## WGS - CNV

### Description
Copy number variation detection using whole genome sequencing.

### Recommended Datasets

| Dataset | Sample Type | Ground Truth | Access | Link |
|--------|------------|-------------|--------|------|
| PCAWG | Tumor | Consensus | Controlled | https://dcc.icgc.org/pcawg |
| TCGA (subset) | Tumor | Partial | Controlled | https://portal.gdc.cancer.gov/ |

### Benchmark Focus
- Genome-wide CNV
- Large-scale amplification/deletion

---

## RNA-seq - Gene Fusion

### Description
Datasets for fusion gene detection benchmarking.

### Recommended Datasets

| Dataset | Sample Type | Ground Truth | Access | Link |
|--------|------------|-------------|--------|------|
| TCGA | Tumor | Partial | Controlled | https://portal.gdc.cancer.gov/ |
| CCLE | Cell line | Partial | Open | https://depmap.org/portal/ |

### Benchmark Focus
- Fusion detection sensitivity
- False positive rate
- Tool comparison (STAR-Fusion, Arriba, etc.)

---

## RNA-seq - Expression / Variant

### Description
RNA-seq datasets for expression quantification or variant calling.

### Recommended Datasets

| Dataset | Sample Type | Ground Truth | Access | Link |
|--------|------------|-------------|--------|------|
| TCGA | Tumor | Partial | Controlled | https://portal.gdc.cancer.gov/ |

### Benchmark Focus
- Expression quantification consistency
- RNA variant detection

---

## Synthetic / Spike-in Datasets

### Description
Artificial datasets with known ground truth for controlled benchmarking.

### Recommended Tools / Datasets

| Dataset | Type | Ground Truth | Link |
|--------|------|-------------|------|
| BAMSurgeon | Spike-in | Yes | https://github.com/adamewing/bamsurgeon |
| VarSim | Simulation | Yes | https://github.com/bioinform/varsim |

### Benchmark Focus
- Sensitivity evaluation
- Controlled experiments
- Edge case testing

---

## Template for Adding New Entries

```yaml
Data Category: (e.g. WGS-SV)
Dataset Name:
Sample Type:
Variant Type:
Ground Truth:
Access:
Download Link:
Recommended Usage:
Notes:
Contributor:
Last Updated: