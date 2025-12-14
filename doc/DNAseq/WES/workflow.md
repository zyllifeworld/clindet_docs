(clindet-wxs-workflow)=
# ClinDet WXS workflow
For better reproducibility, ClinDet incorporates best practices from leading international research institutions, including the [Hartwig Medical Foundation (HMF)](https://github.com/hartwigmedical/hmftools), the [German Cancer Research Center (DKFZ)](https://www.dkfz.de/en/), the [New York Genome Center (NYGC)](https://www.nygenome.org/), the [ICGC-TCGA-PanCancer project](https://github.com/ICGC-TCGA-PanCancer), the [Wellcome Sanger Institute](https://www.sanger.ac.uk/programme/cancer-ageing-and-somatic-mutation/), and the Broad Institute [GATK best practice](https://gatk.broadinstitute.org/hc/en-us/sections/360007226651-Best-Practices-Workflows). 



ClinDet provides two mutation detection modes for tumor samples: tumor-normal paired sample mode and tumor-only mode, to accommodate the testing needs of different clinical cohorts.


- [ClinDet WXS workflow](#clindet-wxs-workflow)
  - [QC and preprocess](#qc-and-preprocess)
  - [Small variants (SNVs/Indels)](#small-variants-snvsindels)
    - [Small variants (SNVs/Indels) (Somatic)](#small-variants-snvsindels-somatic)
      - [Summary](#summary)
      - [Details](#details)
        - [Run SNV, MNV, INDEL calling:](#run-snv-mnv-indel-calling)
        - [Extract passing calls (with PASS in FILTER)](#extract-passing-calls-with-pass-in-filter)
        - [Annotation of mutations](#annotation-of-mutations)
        - [Consensus results from Multiple softwares](#consensus-results-from-multiple-softwares)
    - [SNPs and small indels (Germline)](#snps-and-small-indels-germline)
  - [Copy Number Variants](#copy-number-variants)
    - [Summary](#summary-1)
    - [Calculate BAF and coverage log2ration](#calculate-baf-and-coverage-log2ration)
    - [call segment from BAF and log ratio](#call-segment-from-baf-and-log-ratio)
      - [CNV segment calling: AMBER,  COBALT,  PURPLE, ASCAT,  free-C, sequenza, Facets, ExomdDepth](#cnv-segment-calling-amber--cobalt--purple-ascat--free-c-sequenza-facets-exomddepth)
      - [Plot the segment results](#plot-the-segment-results)
  - [MultiQC](#multiqc)
  - [Case Reports](#case-reports)
  - [Implementation](#implementation)

ClinDet post-processess outputs of cancer variant calling analysis pipelines
from **BAM** from Tumor-Normal paired (Tumor-only model)
and generates reports for researchers and curators at UMCCR.

It takes as input results from the UMCCR DRAGEN Tumor/Normal and DRAGEN Germline
variant calling workflows:

- BAM files from both samples
- somatic small variant calls
- germline small variant calls
- somatic structural variant calls


(qc-and-preprocess)=
## QC and preprocess
In the pre-processing step, ClinDet processes FASTQ files in accordance with GATK best practices.Fastp were used to trim adapter and generate sequencing report of each fastq file. Then trimmed sequence reads were aligned to the reference genome using BWA-MEM, followed by deduplication and recalibration with GATK. Specifically, for tumor-normal paired samples, ConPair is employed to verify whether the samples originate from the same individual, and quality control statistics files are generated via GATK.


fastp is a tool designed to provide ultrafast all-in-one preprocessing and quality control for FastQ data.



[Conpair](https://github.com/nygenome/conpair) is a fast and robust method dedicated for human tumor-normal studies to perform concordance verification (i.e. samples coming from the same individual), as well as cross-individual contamination level estimation in whole-genome and whole-exome sequencing experiments.


(small-variants-snvsindels)=
## Small variants (SNVs/Indels)

(small-variants-snvsindels-somatic)=
### Small variants (SNVs/Indels) (Somatic)

Post-preprocessing BAM files are analyzed using various software tools. For somatic mutations, 11 software tools are utilized for detection. To exclude germline mutations and sequencing artifacts from the final results as comprehensively as possible (particularly for tumor-only samples), ClinDet supports a [panel of normals](https://github.com/umccr/vcf_stuff/blob/master/vcf_stuff/panel_of_normals/story/panel_of_normals.md) strategy to mark and filter variants, which has been demonstrated to effectively remove germline variants and recurrent technical artifacts. Users may specify pre-built VCF files or employ ClinDet to construct them de-novo based on normal sample data from the cohort. The remaining detected results (in VCF format) are filtered and annotated using the [vcf2maf](https://github.com/mskcc/vcf2maf) software to produce MAF files. Subsequently, these MAF-format outputs from all SNV callers are processed through a custom R script to generate consensus mutation detection results. For somatic structural variations, ClinDet employs five software tools for detection; to achieve consensus results, [Jasmine](https://github.com/mkirsche/Jasmine) software is used to merge structural variation events sharing the same orientation and breakpoint positions within 500bp. For copy number variations, ClinDet utilizes seven software tools for detection and organizes the final results into segment-format files. Users can select specific software for subsequent analyses according to their requirements.


(summary)=
#### Summary

1. **Call** candidate variants using multiple softwares.
2. **Keep** variants with FILTER=='PASS' in vcf.
3. **Keep** variants that are in the auto/sex/mito chromosomes (1-22, X, Y, M).
4. **Annotate** variants with info from databases/files.
5. **Consensus** results from multiple softwares.



(details)=
#### Details

Steps are:
##### Run SNV, MNV, INDEL calling:
[SAGE](https://github.com/hartwigmedical/hmftools/tree/master/sage), [HaplotypeCaller](https://github.com/broadinstitute/gatk), [Mutect2](https://github.com/broadinstitute/gatk), [Strelka](https://github.com/Illumina/strelka), [CaVEMan](https://github.com/cancerit/CaVEMan), [Varscan](https://varscan.sourceforge.net/), [Muse](https://bioinformatics.mdanderson.org/public-software/muse/), [Pindel](https://github.com/cancerit/cgpPindel), [DeepVariant](https://github.com/google/deepsomatic), [Lofreq](https://csb5.github.io/lofreq/)

  - [**SAGE**](https://github.com/hartwigmedical/hmftools/tree/master/sage) is an in-house tool (java) developed by the Hartwig Medical Foundation for somatic variant calling, specifically designed to identify somatic variants such as multi-nucleotide variants (MNVs), single-nucleotide variants (SNVs), and indels by comparing tumor and reference samples. sage called variants can be annotated by [pave](https://github.com/hartwigmedical/hmftools/tree/master/pave) or generated report by purple. This tool only support *human* genome (b37 nochr prefix, hg38 with chr prefix).

  - **HaplotypeCaller**, part of the Genome Analysis Toolkit (GATK), is utilized for variant calling to identify single-nucleotide polymorphisms (SNPs) and indels through local de-novo assembly of haplotypes in active genomic regions. It processes aligned reads in BAM or CRAM formats to produce VCF files, often as part of best-practice workflows following base quality score recalibration and prior to variant filtration, emphasizing accuracy in complex variation regions.

  - **Mutect2**, integrated within the Genome Analysis Toolkit (GATK) version 4 and later, serves as a somatic variant caller to detect mutations in tumor samples by comparing them to matched normal samples using a Bayesian model. It focuses on identifying SNPs and small indels with high sensitivity and specificity for cancer genomics, supporting scalable processing in local or cloud environments via Apache Spark.

  - **Strelka2** is a small variant caller optimized for detecting germline and somatic variations in small cohorts and somatic variations in tumor-normal pairs, employing tiered haplotype models and mixture-model indel error estimation for improved accuracy. It accepts BAM or CRAM inputs and outputs VCF 4.1 files, with features like read-backed phasing and empirical variant re-scoring; for best somatic indel performance, it is recommended to pair it with the Manta structural variant caller.

  - **CaVEMan** is a somatic mutation detection algorithm tailored for paired tumor-normal cancer samples, using an expectation maximization approach to call single-nucleotide variants (SNVs). It supports BAM and CRAM formats, processes data through steps like genome splitting, Mstep for probability calculations, and Estep for variant calling, producing VCF files; it is optimized for cluster environments and can incorporate copy number data for better accuracy. This tool need a CNVs segment results from other softwares (eg. ASCAT).  This tool need many config files, see [caveman config](https://github.com/cancerit/cgpCaVEManWrapper) to know howto prepare those files for other species.

  - **VarScan** is a platform-independent tool for variant detection in next-generation sequencing data, compatible with platforms like Illumina and Roche/454, for targeted, exome, or whole-genome resequencing. It applies heuristic and statistical thresholds for read depth, base quality, and allele frequency to identify variants in complex samples, including those with contamination, and is developed in Java for broad operating system compatibility.

  - **MuSE** is a **fast** somatic point mutation caller for tumor-normal paired next-generation sequencing data, employing a Markov substitution model to account for inter-tumor heterogeneity and improve sensitivity/specificity via a sample-specific error model. It has been utilized in major projects like TCGA PanCanAtlas; MuSE 2.0 leverages parallel computing for rapid processing, completing whole-exome sequencing in minutes and whole-genome in under an hour with multiple cores.

  - **Pindel**, within the Cancer Genome Project's cgpPindel pipeline, is designed for detecting insertions, deletions, and structural variants from tumor and normal BAM alignments. It converts Pindel text outputs to VCF formats and applies filters, with CGP-specific modifications for enhanced analysis.

  - **DeepVariant** is a deep learning-based variant caller developed by Google, utilizing convolutional neural networks to analyze aligned sequencing reads and accurately identify single-nucleotide variants (SNVs), insertions, and deletions (indels). It transforms variant calling into an image classification problem, achieving high precision across whole-genome sequencing (WGS), whole-exome sequencing (WES), and other data types, with support for multiple sequencing platforms; it is particularly noted for its robustness in handling noisy data and has been validated in precisionFDA challenges for superior performance in germline and somatic variant detection.

  - **LoFreq** is a sensitive and fast variant caller designed for detecting low-frequency single-nucleotide variants (SNVs) and indels in heterogeneous samples, such as viral populations or cancer genomes, using a Poisson-binomial distribution to model sequencing errors. It excels in identifying rare variants below typical detection thresholds, processes BAM files efficiently without requiring matched normals, and includes features like strand-bias filtering and parallelization for scalability in high-throughput analyses.

  - **VarDict** is a variant discovery program, initially developed in Perl and ported to Java, designed for sensitive variant calling from BAM files in next-generation sequencing, particularly for cancer genomics. Its primary purpose is to detect single nucleotide variants (SNVs), insertions, deletions, and structural variants in both single and paired sample analyses. Key features include amplicon bias awareness for targeted sequencing, rescue of long indels through realignment of soft-clipped reads, and improved scalability, with the Java port being approximately 10x faster than the original Perl implementation. It supports various modes such as single sample, paired sample, and amplicon-based calling, utilizing inputs like reference genomes in FASTA format, aligned reads in BAM format, and target regions in BED format. Applications are prominent in cancer research, facilitating the identification of somatic mutations and other genomic alterations.
  
##### Extract passing calls (with PASS in FILTER)

ClinDet use bcftools to filter `PASS` variants.
 
##### Annotation of mutations
The called results (in VCF format) are filtered and annotated using the vcf2maf software to produce MAF files. This tool is based on VEP, so user can add some VEP plugins.

##### Consensus results from Multiple softwares
Subsequently, all MAF-format outputs from all SNV callers are processed through a custom R script to generate consensus mutation detection results. For somatic structural variations, ClinDet employs five software tools for detection; to achieve consensus results, Jasmine software is used to merge structural variation events sharing the same orientation and breakpoint positions within 500bp. For copy number variations, ClinDet utilizes seven software tools for detection and organizes the final results into segment-format files. Users can select specific software for subsequent analyses according to their requirements.


(snps-and-small-indels-germline)=
### SNPs and small indels (Germline)
ClinDet filter germline variant from calling results of **strelka,caveman,vardict**.

## Copy Number Variants

ClinDet uses multiple software tools to call arm-level CNVs. Some of these tools are based on the [BAF](https://cnvkit.readthedocs.io/en/stable/baf.html) of known SNPs, which can be calculated using [alleleCount](https://github.com/cancerit/alleleCount) may only work for human. Others are coverage- (or depth-) based (e.g., FREEC, Sequenza), which may be time-consuming, but can be applied to any species (such as worm and mouse). Users can choose the tool that best suits their needs.

### Summary

### Calculate BAF and coverage log2ration
   SNPs from human 1000 genome project will be used by alleleCountr or AMBER to get base counts of each loci, and then Calculate B-allele frequencies. Next, Sample  gender will be determined by sex chromosomes' coverage (**ASCAT can corrected these values by GC-contents and replication times**). Furthermore, the purity and ploidy will be estimated by grid search.
### call segment from BAF and log ratio
#### CNV segment calling: [AMBER](https://github.com/hartwigmedical/hmftools/tree/master/amber),  [COBALT](https://github.com/hartwigmedical/hmftools/tree/master/cobalt),  [PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purple), [ASCAT](https://github.com/VanLoo-lab/ascat),  [free-C](https://github.com/BoevaLab/FREEC), [sequenza](https://github.com/oicr-gsi/sequenza), [Facets](https://github.com/mskcc/facets), [ExomdDepth](https://github.com/vplagnol/ExomeDepth)
    
  - **AMBER** is an in-house tool developed by the Hartwig Medical Foundation (HMF) for estimating allele-specific copy numbers in tumor samples. It analyzes B-allele frequencies (BAFs) of heterozygous germline variants to infer minor allele copy numbers, aiding in the detection of somatic copy number alterations (CNAs) in cancer genomics. Integrated into HMF pipelines like Pipeline5, it supports whole-genome sequencing (WGS) data processing, contributing to accurate tumor ploidy and purity assessments.

  - **COBALT** is an in-house tool from the Hartwig Medical Foundation (HMF) designed for copy number normalization in tumor samples using read-depth ratios. It corrects for GC bias and other sequencing artifacts to generate reliable logR profiles, essential for downstream copy number variation (CNV) analysis in cancer genomics. Part of HMF's Pipeline5, it processes BAM files from whole-genome sequencing (WGS), enhancing the precision of somatic variant calling and structural analysis.

  - **PURPLE** is an in-house tool developed by the Hartwig Medical Foundation (HMF) for comprehensive copy number analysis in cancer genomes. It integrates read-depth ratios from COBALT, B-allele frequencies (BAFs) from AMBER, and structural/somatic variants to estimate tumor purity, ploidy, and allele-specific copy numbers. Featured in HMF's Pipeline5, it produces detailed CNV profiles from whole-genome sequencing (WGS) data, supporting driver gene identification and tumor heterogeneity studies in oncology.

  - **ASCAT** is an R package for inferring tumor purity, ploidy, and allele-specific copy number profiles from genomic data, primarily in cancer genomics. It processes high-throughput sequencing (HTS) data like whole-exome sequencing (WES), whole-genome sequencing (WGS), and targeted sequencing (TS), with features including logR correction for GC content and replication timing, colorblind-friendly visualizations, and support for long-read sequencing. It leverages heterozygous SNPs for CNA calling and provides reference files for various platforms.

  - **FREEC** (Control-FREEC) is a tool for detecting copy-number changes and allelic imbalances, including loss of heterozygosity (LOH), using deep-sequencing data in whole-genome and whole-exome sequencing. It automatically computes, normalizes, and segments copy number and BAF profiles, calling CNAs and LOH with optional matched normal controls. Features include subclonal gain/loss detection, contamination evaluation, and support for BAM/SAM inputs, making it suitable for cancer genomics to identify genomic alterations.

  - **Sequenza** is a workflow for estimating cellularity and ploidy, providing allele-specific copy numbers and log-posterior probabilities based on B-allele frequency and depth ratios. It processes SNP and CNV data from tools like Varscan, supporting segmentation with tunable gamma parameters and generating outputs such as JSON files, summary plots, and Rmarkdown reports. Used in cancer genomics for analyzing tumor purity and copy number variations from sequencing data.

  - **FACETS** is an algorithm for estimating the fraction of tumor cells and allele-specific copy numbers from tumor-normal sequencing data. It performs joint segmentation to output copy number profiles, diploid log-ratio values, and flags for estimation issues, with support for clonal cluster analysis. Implemented in R, it requires dependencies like pctGCdata and is used in cancer genomics to analyze somatic alterations and tumor purity from BAM files.

  - **ExomdDepth** ExomeDepth is a R package designed to detect inherited copy number variants (CNVs) using high throughput DNA sequence data. While Exome is included in the name of the package it in fact performs best on smaller panels, because the analytics of the package leverage the tight correlation structure between the (often) large number of samples being run in parallel. These tight correlations is what ExomeDepth looks for when building a reference sample for each test sample and the quality of the output will typically vary depending on that correlation structure. Note that while it can be used in the context of tumour/control matched pairs, this is not the initial intent of the tools and the performances in that context are largely untested.

#### Plot the segment results
   CNVs results called by each tool can be visualized by circos and R, see results folder of each tool.


## MultiQC

Following the derivation of consensus SNVs, CNVs, and SVs from all samples, ClinDet generates a comprehensive array of quality control metrics using Fastp, ConPair, GATK, and Samtools, which are visualized as an aggregated quality control review across samples via MultiQC.

## Case Reports
To enhance the clinical applicability of the detection results, ClinDet employs R Markdown and HMF [ORANGE](https://github.com/hartwigmedical/hmftools/tree/master/orange) software to visualize the consensus outputs for each patient (tumor-normal paired), ultimately generating a structured HTML report file. This report includes basic sample information, potential cancer driver genes identified from the mutation detection results, and targetable sites, to support the selection of patient treatment regimens.

## Implementation

The ClinDet pipeline tool was developed using Snakemake, following a clean, and robust design in accordance with best practice coding standards. Instructions for installing and running ClinDet are provided in the public GitHub repository (https://github.com/zyllifeworld/clindet). A detailed manual, which outlines the workflows and operating parameters, is also available on the GitHub README page. To ensure the reproducibility of data analyses and to mitigate the challenges associated with dependency configuration in bioinformatics tool installations, multiple containers for analysis software were constructed using an integrated approach involving Conda, Docker, and Singularity. Leveraging container technology, ClinDet can be deployed seamlessly on any Linux-compatible computing system. The runtime parameters of these software tools are managed via a YAML-format configuration file, enabling users to readily modify them according to specific analysis requirements, such as the genome version required for alignment or the allocation of computational resources for tasks. Additionally, owing to Snakemake's flexible syntax, users can easily add, delete, or modify steps in the data analysis workflow.

> support genome version for each tool was listd below:

:::{table} ClinDet WES mutation call module
:align: center
:widths: auto
| Softwares | Tumor-Nomral paired | Tumor-only | Support genome version |
| --- | --- | --- | --- |
| GATK HaploCallers | Yes | Yes | b37,hg19,hg38,T2T |
| Mutect2 | Yes  | Yes | b37,hg19,hg38,T2T |
| DeepVariant  | Yes | Yes | b37,hg19,hg38,T2T |
| Strelka  | Yes | Yes | b37,hg19,hg38,T2T |
| Sage  | Yes | Yes | b37,hg38 |
| Vardict  | Yes  | No | b37,hg19,hg38,T2T |
| CaVEMan  | Yes | No | b37,hg19,hg38,T2T |
| Varscan  | Yes | No | b37,hg19,hg38,T2T |
| Muse  | Yes | No | b37,hg19,hg38,T2T |
| Lofreq  | Yes | No | b37,hg19,hg38,T2T |
| cgppindel| Yes | No | b37,hg19,hg38,T2T |
| Manta| Yes | No | b37,hg19,hg38,T2T |
:::