# Clindet
[![Snakemake](https://img.shields.io/badge/snakemake-≥5.6.0-brightgreen.svg?style=flat)](https://snakemake.readthedocs.io)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.15787887-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.15787887)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Github](https://img.shields.io/github/stars/clindet/clindet?style=social)](https://github.com/clindet/clindet/stargazers)

## Introduction
Clindet is an Next generation High throughout sequencing data  analysis wrokflow for clinical applications (eg. DNA-seq )
**Clindet** is a snakemake pipeline for the comprehensive analysis of cancer genomes and transcriptomes using multiple state-of-art softwares to get consensus results. The pipeline
supports a wide range of experimental setups:

- FASTQ
- WGS (whole genome sequencing), WTS (whole transcriptome sequencing), and targeted / panel sequencing 
- Paired tumor / normal and tumor-only sample setups
- Most GRCh37 and GRCh38 reference genome builds
- Non-human species(eg, mouse, worm).

## Pipeline overview

```{image} ../img/clindet_pipeline.png
:alt: fishy
:class: bg-primary
:width: 500px
:align: center
```

## Steps
- Quality Control: ([Conpair](https://github.com/nygenome/Conpair), [fastp](https://github.com/OpenGene/fastp))
- Read alignment: ([BWA-MEM2](https://github.com/bwa-mem2/bwa-mem2) (DNA), [STAR](https://github.com/alexdobin/STAR) (RNA))
- Read post-processing: ([GATK MarkDuplicates](https://gatk.broadinstitute.org/hc/en-us/articles/360037052812-MarkDuplicates-Picard) (DNA,RNA) )
- SNV, MNV, INDEL calling: 
([SAGE](https://github.com/hartwigmedical/hmftools/tree/master/sage), [HaplotypeCaller](https://github.com/broadinstitute/gatk),
[Mutect2](https://github.com/broadinstitute/gatk),
[Strelka](https://github.com/Illumina/strelka),
[CaVEMan](https://github.com/cancerit/CaVEMan),
[Varscan](https://varscan.sourceforge.net/),
[Muse](https://bioinformatics.mdanderson.org/public-software/muse/),
[Pindel](https://github.com/cancerit/cgpPindel)
)

- SV calling: 
(
[ESVEE](https://github.com/hartwigmedical/hmftools/tree/master/esvee),
[Manta](https://github.com/hartwigmedical/hmftools/tree/master/esvee),
[Delly](https://github.com/hartwigmedical/hmftools/tree/master/esvee),
[svaba](https://github.com/hartwigmedical/hmftools/tree/master/esvee),
[gridss](https://github.com/hartwigmedical/hmftools/tree/master/esvee)
)
- CNV calling: 
([AMBER](https://github.com/hartwigmedical/hmftools/tree/master/amber), 
[COBALT](https://github.com/hartwigmedical/hmftools/tree/master/cobalt), 
[PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purple), 
[ASCAT](https://github.com/VanLoo-lab/ascat), 
[free-C](https://github.com/BoevaLab/FREEC), 
[Battebberg](https://github.com/Wedge-lab/battenberg), 
[sequenza](https://github.com/oicr-gsi/sequenza), 
[Facets](https://github.com/mskcc/facets), 
[Dryclean](https://github.com/mskilab-org/dryclean))

- SV and driver event interpretation: [LINX](https://github.com/hartwigmedical/hmftools/tree/master/linx)
- RNA transcript analysis: 
[RSEM](https://github.com/deweylab/RSEM)

- RNA fusion gene detection: 
[Arriba](https://github.com/suhrig/arriba)

- Oncoviral detection: [VIRUSbreakend](https://github.com/PapenfussLab/gridss)\*, [VirusInterpreter](https://github.com/hartwigmedical/hmftools/tree/master/virus-interpreter)\*
- Telomere characterisation: [TEAL](https://github.com/hartwigmedical/hmftools/tree/master/teal)\*
- Immune analysis: [LILAC](https://github.com/hartwigmedical/hmftools/tree/master/lilac), [CIDER](https://github.com/hartwigmedical/hmftools/tree/master/cider), [NEO](https://github.com/hartwigmedical/hmftools/tree/master/neo)\*
- Mutational signature fitting: [SIGS](https://github.com/hartwigmedical/hmftools/tree/master/sigs)\*
- HRD prediction: [CHORD](https://github.com/hartwigmedical/hmftools/tree/master/chord)\*
- Tissue of origin prediction: [CUPPA](https://github.com/hartwigmedical/hmftools/tree/master/cuppa)\*

- Summary report: [ORANGE](https://github.com/hartwigmedical/hmftools/tree/master/orange)

## Usage

````{note}
> If you are new to snakemake, please refer to [this page](https://snakemake.readthedocs.io/en/stable/) on how to set-up snakemake. Make sure to test your setup before running the workflow on actual data.
````


Create a samplesheet with your inputs (WGS/WES *fastq in this example):

```csv
Tumor_R1_file_path,Tumor_R2_file_path,Normal_R1_file_path,Normal_R2_file_path,Sample_name,Target_file_bed,Project
Patient1_T_R1.fq.gz,Patient1_T_R2.fq.gz,Patient1_N_R1.fq.gz,Patient1_N_R2.fq.gz,Patient1,target.bed,WES
Patient2_T_R1.fq.gz,Patient2_T_R2.fq.gz,,,Patient2,target.bed,WES
```


````{note}
> It is recommended to create a Snakemake file for each project. Specific examples can be found in the Clindet directory, including **snake_wes_template.smk**, **snake_wgs_template.smk**, **and snake_rna_template.smk**. Project-specific parameters can be modified within these files.
````

Launch `Clindet`:

```bash
nohup snakemake --profile workflow/config_slurm -j 40 --printshellcmds \
--use-singularity -s snake_wes.smk \
--latency-wait 300 --use-conda --conda-frontend conda  -k >> Log.out &
```

````{warning}
> If you do not need to submit and run tasks on the Slurm platform, there is no need to specify the ** --profile ** parameter.
````

## Credits

The `Clindet` pipeline was written and is maintained by Yuliang Zhang ([@Yuliang Zhang](https://github.com/zyllifeworld)) , XXX from
the [National Research Center for Translational Medicine at Shanghai](https://github.com/clindet).

We thank the following organisations and people for their extensive assistance in the development of this pipeline,
listed in alphabetical order:

- [Hartwig Medical Foundation Australia](https://www.hartwigmedicalfoundation.nl/en/partnerships/hartwig-medical-foundation-australia/)
- [Broad Institute](https://www.broadinstitute.org/)
- [German Cancer Research Center](https://www.dkfz.de/en/)
- [Wellcome Sanger Institute](https://www.sanger.ac.uk/)
- [New York Genome Center](https://www.nygenome.org/)
- JianFeng Li
