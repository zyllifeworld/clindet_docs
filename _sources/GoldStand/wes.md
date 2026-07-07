# Capability-Driven Benchmark Matrix

## Overview
This document organizes benchmark resources by analytical capability rather than by dataset name alone. It is intended to function as the task matrix of the GoldStand benchmark gym: each section links a workflow capability to one or more recommended datasets, the strength of available truth, the expected outputs, and the main evaluation purpose.

This matrix is useful for:

- selecting datasets for a specific workflow function
- planning smoke, standard, gold, or stress tests
- comparing tool behavior across omics tasks
- tracking which ClinDet modules are already covered and which still need reference data

## How to read this matrix
Each benchmark category should be interpreted through four questions:

1. What capability is being tested?
2. What kind of truth or expectation is available?
3. What outputs should be inspected after a successful run?
4. Is the dataset best suited for smoke testing, routine validation, or rigorous benchmarking?

## Capability categories

- [WES - Somatic SNV / Indel](#wes---somatic-snv--indel)
- [WES - CNV](#wes---cnv)
- [WGS - Germline SNV / Indel](#wgs---germline-snv--indel)
- [WGS - Somatic SNV / Indel](#wgs---somatic-snv--indel)
- [WGS - Structural Variants](#wgs---structural-variants)
- [WGS - CNV](#wgs---cnv)
- [RNA-seq - Fusion Detection](#rna-seq---fusion-detection)
- [RNA-seq - Expression Quantification](#rna-seq---expression-quantification)
- [RNA-seq - Immune Repertoire / Transcript-derived Features](#rna-seq---immune-repertoire--transcript-derived-features)
- [Synthetic and Spike-in Validation](#synthetic-and-spike-in-validation)

## WES - Somatic SNV / Indel

### Capability
Benchmark somatic SNV and small Indel detection in tumor-normal or synthetic exome settings.

### Recommended datasets

| Dataset | Sample Type | Truth Strength | Access | Recommended Level | Expected Outputs |
|--------|-------------|----------------|--------|-------------------|------------------|
| SEQC2 / MAQC | Synthetic / mixture | Known spike-in | Open | Gold | VCF, MAF |
| TCGA | Tumor / Normal | Partial | Controlled | Standard | VCF, MAF |
| BostonGene reference standards | Cell line / reference | Partial | Open | Standard | VCF, MAF |

### Evaluation focus

- sensitivity at low VAF
- precision / recall across callers
- concordance between somatic callers
- impact of filtering strategy on final MAF output

## WES - CNV

### Capability
Benchmark exome-based copy-number recovery from targeted coverage profiles.

### Recommended datasets

| Dataset | Sample Type | Truth Strength | Access | Recommended Level | Expected Outputs |
|--------|-------------|----------------|--------|-------------------|------------------|
| TCGA | Tumor | Partial | Controlled | Standard | CNV segments, plots |
| CCLE | Cell line | Partial | Open | Standard | CNV segments, plots |
| COLO829 WES subsets | Tumor / Normal | Partial | Open | Stress | CNV segments, purity/ploidy |

### Evaluation focus

- exon-level CNV recovery
- stability under noisy coverage
- agreement between CNV callers
- large-scale amplification and deletion detection

## WGS - Germline SNV / Indel

### Capability
Benchmark high-confidence germline small-variant calling.

### Recommended datasets

| Dataset | Sample Type | Truth Strength | Access | Recommended Level | Expected Outputs |
|--------|-------------|----------------|--------|-------------------|------------------|
| GIAB | Germline reference | High-confidence | Open | Gold | VCF |
| Cancer Genome in a Bottle normal samples | Germline / matched normal | High-confidence subset | Open | Gold | VCF |

### Evaluation focus

- precision / recall in confident regions
- consistency across versions
- difficult-region behavior

## WGS - Somatic SNV / Indel

### Capability
Benchmark somatic small-variant detection in tumor-normal whole-genome data.

### Recommended datasets

| Dataset | Sample Type | Truth Strength | Access | Recommended Level | Expected Outputs |
|--------|-------------|----------------|--------|-------------------|------------------|
| Cancer Genome in a Bottle | Tumor / Normal | High-confidence subset | Open | Gold | VCF, MAF |
| PCAWG | Tumor / Normal | Consensus | Controlled | Gold | VCF, MAF |
| COLO829 | Tumor / Normal | Partial to strong, task-dependent | Open | Standard | VCF, MAF |

### Evaluation focus

- genome-wide somatic accuracy
- low-frequency mutation sensitivity
- caller agreement and post-filtering stability

## WGS - Structural Variants

### Capability
Benchmark somatic structural-variant detection and breakpoint recovery.

### Recommended datasets

| Dataset | Sample Type | Truth Strength | Access | Recommended Level | Expected Outputs |
|--------|-------------|----------------|--------|-------------------|------------------|
| PCAWG | Tumor / Normal | Consensus | Controlled | Gold | SV VCF, merged SV set |
| ICGC | Tumor | Curated | Controlled | Gold | SV VCF |
| COLO829 | Tumor / Normal | Partial / benchmark-like | Open | Standard | SV VCF, merged SV set |

### Evaluation focus

- breakpoint resolution
- event class coverage
- false-positive burden by caller
- benefit of multi-caller integration

## WGS - CNV

### Capability
Benchmark whole-genome copy-number analysis, including broad arm-level and focal events.

### Recommended datasets

| Dataset | Sample Type | Truth Strength | Access | Recommended Level | Expected Outputs |
|--------|-------------|----------------|--------|-------------------|------------------|
| PCAWG | Tumor / Normal | Consensus | Controlled | Gold | segments, purity/ploidy |
| COLO829 | Tumor / Normal | Partial / benchmark-like | Open | Standard | segments, purity/ploidy |
| TCGA selected WGS subsets | Tumor | Partial | Controlled | Stress | segments, plots |

### Evaluation focus

- genome-wide CNV structure
- purity and ploidy estimation
- reproducibility across CNV callers

## RNA-seq - Fusion Detection

### Capability
Benchmark fusion transcript detection in RNA-seq.

### Recommended datasets

| Dataset | Sample Type | Truth Strength | Access | Recommended Level | Expected Outputs |
|--------|-------------|----------------|--------|-------------------|------------------|
| CCLE | Cell line | Partial | Open | Standard | fusion TSV |
| TCGA | Tumor | Partial | Controlled | Standard | fusion TSV |
| curated MM / leukemia case datasets | Tumor | Partial / orthogonal | Mixed | Standard | fusion TSV, supporting reads |

### Evaluation focus

- fusion sensitivity
- false-positive burden
- reproducibility across tools
- consistency with orthogonal biology

## RNA-seq - Expression Quantification

### Capability
Benchmark transcript and gene-level quantification.

### Recommended datasets

| Dataset | Sample Type | Truth Strength | Access | Recommended Level | Expected Outputs |
|--------|-------------|----------------|--------|-------------------|------------------|
| TCGA | Tumor | Relative expectation | Controlled | Standard | counts, TPM |
| CCLE | Cell line | Relative expectation | Open | Standard | counts, TPM |
| curated multiple myeloma or cohort RNA cases | Tumor | Biological expectation | Mixed | Smoke, Standard | counts, TPM |

### Evaluation focus

- consistency across quantification methods
- expression ranking stability
- expected overexpression of known marker genes

## RNA-seq - Immune Repertoire / Transcript-derived Features

### Capability
Benchmark repertoire reconstruction and related RNA-derived immunologic readouts.

### Recommended datasets

| Dataset | Sample Type | Truth Strength | Access | Recommended Level | Expected Outputs |
|--------|-------------|----------------|--------|-------------------|------------------|
| multiple myeloma RNA cohorts | Tumor | Biological expectation | Mixed | Standard | clonotype reports |
| TCGA immune-rich cohorts | Tumor | Partial | Controlled | Stress | clonotype reports, summary tables |

### Evaluation focus

- clonality signal recovery
- consistency with disease biology
- robustness across sample quality and depth

## Synthetic and Spike-in Validation

### Capability
Test pipeline behavior in fully controlled or edge-case scenarios.

### Recommended datasets and tools

| Dataset / Tool | Use Case | Truth Strength | Recommended Level | Expected Outputs |
|----------------|----------|----------------|-------------------|------------------|
| BAMSurgeon | Spike-in somatic mutation benchmarking | Exact | Gold | VCF, MAF |
| VarSim | Simulated variant benchmarking | Exact | Gold | VCF |
| custom spike-in RNA controls | Fusion / expression stress tests | Exact or designed | Stress | fusion TSV, counts |

### Evaluation focus

- low-frequency sensitivity
- controlled failure analysis
- edge-case regression testing

## Dataset selection rules
When choosing a dataset for the benchmark gym, prefer the smallest dataset that still answers the validation question:

1. use smoke datasets to test whether the pipeline can run
2. use standard datasets to validate everyday workflow behavior
3. use gold datasets for regression tracking and tool comparison
4. use stress datasets for robustness and edge-case evaluation

## Template for new benchmark entries

```yaml
Capability:
Omics Type:
Dataset Name:
Biological Context:
Supported Tasks:
Expected Outputs:
Truth Strength:
Benchmark Level:
Access:
Download Link:
Evaluation Focus:
Known Caveats:
Recommended Usage:
Contributor:
Last Updated:
```
