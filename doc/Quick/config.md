# Configuring the workflow

Clindet is configured through four YAML files located under `workflow/config/conf/`. Each file controls a distinct aspect of the workflow. The defaults are based on software best practices and validated across a wide range of cancer datasets — beginners can use them as-is. Experienced users may customize individual files to fit their environment and analysis needs.

| Config file | Purpose |
|---|---|
| `genomes.yaml` | Genome reference files (FASTA, dbSNP, GTF, tool-specific resources) |
| `singularity.yaml` | Singularity image locations and pull addresses |
| `softwares.yaml` | Conda environment names for each tool |
| `softwares_params.yaml` | Per-tool runtime parameters |

## genomes.yaml

This file defines reference genome resources. The top-level `resources` key holds one entry per genome version. Each entry name is the **genome version identifier** — the value you set as `project.genome_version` in your project config. The example below shows the `b37` entry:

```yaml
resources:
  b37:
    REFFA: "resources/ref_genome/b37/Homo_sapiens.GRCh37.GATK.illumina.fasta"
    GENOME_BED: ""
    GTF: "resources/ref_genome/b37/Homo_sapiens.GRCh37.87.gtf"
    GFF: "resources/ref_genome/b37/Homo_sapiens.GRCh37.87.gff3"
    WES_PON: "resources/ref_genome/b37/Mutect2-exome-panel.vcf"
    WES_BED: "reference/b37/b37.exon.bed"
    WGS_PON: "resources/ref_genome/b37/Mutect2-WGS-panel-b37.vcf"
    DBSNP: "resources/ref_genome/b37/Homo_sapiens_assembly19.dbsnp138.vcf"
    DBSNP_GZ: "resources/ref_genome/b37/Homo_sapiens_assembly19.dbsnp138.vcf.gz"
    DBSNP_INDEL: "resources/ref_genome/b37/Homo_sapiens_assembly19.dbsnp138.indel.vcf.gz"
    MUTECT2_VCF: "resources/ref_genome/b37/af-only-gnomad.raw.sites.vcf"
    REFFA_DICT: "resources/ref_genome/b37/Homo_sapiens.GRCh37.GATK.illumina.fasta"
    MUTECT2_germline_vcf: "resources/ref_genome/b37/af-only-gnomad.raw.sites.vcf"
    common_vcf: "resources/ref_genome/b37/00-common_all.vcf.gz"
    RNA_EDIT_VCF: "resources/ref_genome/b37/b37.RNAediting.vcf.gz"
```

Each field under a genome version entry is explained below. Fields left as `""` are optional — the workflow will skip the corresponding tool or annotation step for that genome.

### Field descriptions

`REFFA`
: Path to the reference genome FASTA file. Used by all aligners (BWA, STAR) and GATK tools. Must be accompanied by a `.fai` index in the same directory.

`REFFA_DICT`
: Sequence dictionary (`.dict`) companion to `REFFA`. Generated with `picard CreateSequenceDictionary`. Required by GATK and Picard tools.

`GTF`
: Gene annotation in GTF format. Used by STAR (alignment), RSEM (expression quantification), VEP (variant effect prediction), and featureCounts (coverage counting).

`GFF`
: Gene annotation in GFF3 format. Optional for human genomes; used by certain annotation tools. Leave empty if not needed.

`GENOME_BED`
: Genome-wide BED file defining all calling regions. Typically left empty for WES/panel analyses because the target BED is provided per-sample via the `Target_file_bed` column in the sample sheet. Set this only for whole-genome analyses without a per-sample BED.

`WES_BED`
: Exome capture target BED for the genome version. Used by WES coverage tools and CNV callers. Obtain this from your sequencing provider or generate it from the GTF (see [Generate a BED File for WES Analysis](../Quick/install#generate-a-bed-file-for-wes-analysis)).

`WES_PON`
: Panel of Normals for Mutect2 somatic calling in exome mode. A VCF of common germline variants from a cohort of normal samples run on the same capture kit.

`WGS_PON`
: Panel of Normals for Mutect2 in whole-genome mode. Equivalent to `WES_PON` but for WGS data.

`DBSNP`
: dbSNP known-sites VCF (uncompressed). Used by GATK BaseRecalibrator (BQSR) and VEP annotation.

`DBSNP_GZ`
: dbSNP known-sites VCF (gzipped). Alternative compressed form of the same resource. At least one of `DBSNP` or `DBSNP_GZ` must be set for BQSR.

`DBSNP_INDEL`
: dbSNP INDEL-only known-sites VCF. Additional input for GATK BQSR to improve INDEL base quality recalibration.

`MUTECT2_VCF`
: Population allele-frequency VCF (typically gnomAD). Used by Mutect2 as a background population resource during somatic variant filtering.

`MUTECT2_germline_vcf`
: Population resource VCF for germline variant filtering. Often the same file as `MUTECT2_VCF`.

`common_vcf`
: High-frequency common variant VCF. Used during variant filtration to flag or remove variants with high population allele frequencies.

`RNA_EDIT_VCF`
: Known RNA-editing sites in VCF format. Used during RNA-seq variant calling to mask sites that are likely RNA-editing events rather than true genomic variants. Leave empty if not performing RNA variant calling.

### Adding a custom genome

You can add any species' genome by creating a new key under `resources` with the same set of fields. Point each field to the corresponding reference file, or leave it empty (`""`) if a resource is not available. However, you are responsible for providing the correct reference files for your species — ensure the FASTA, GTF/GFF, dbSNP, and population-frequency VCF files are appropriate for your organism based on domain knowledge. Reference the key name as `project.genome_version` in your project config.

## singularity.yaml

This file maps each tool to its Singularity container image. Each entry has two primary fields, plus optional tool-specific extras:

```yaml
singularity:
  caveman:
    sif: "resources/containers/caveman153.sif"
    repo: "docker://quay.io/wtsicgp/cgpcavemanwrapper:1.15.3"
  freec:
    sif: "resources/containers/control-freec-11.6.sif"
    repo: "docker://quay.io/biocontainers/control-freec:11.6b--h503566f_2"
    config_wes: "workflow/WES/scripts/freec/config_exome.ini"
  arriba:
    sif: "resources/containers/arriba240.sif"
    repo: "docker://uhrigs/arriba:2.4.0"
    call: "/arriba_v2.4.0/arriba"
```

### Field descriptions

`sif`
: Local path to the Singularity image (`.sif` file), relative to the Clindet repository root. If the file exists, Singularity uses it directly without pulling. If left empty (e.g., `sequenza` in the default config), the image will be pulled from `repo` at runtime.

`repo`
: Remote registry URI from which to pull the image. Supports `docker://` (Docker Hub / Quay.io) and `https://` (Galaxy Depot / direct Singularity registry) schemes.

Some tools declare additional fields:

- `config_wes` / `config_wgs` — path to a tool-specific configuration template (e.g., Control-FREEC exome INI)
- `call` — path to the main executable inside the container, used when the container's default entrypoint is not the desired command

## softwares.yaml

This file maps each tool to its Conda environment name. The default file ships with the recommended environment names as shown below:

```yaml
conda:
    clindet_main: 'clindet'
    multiqc: 'clindet'
    clindet_rsem: 'clindet_rsem'
    clindet_vep: 'clindet_vep'
    facets:
    hmftools: 'hmftools'
    strelka: 'strelka'
    trust4: 'clindet_rsem'
    rna: 'clindet_rsem'
    clindet_mut: "clindet_mutflag"
```

> **Important:** Replace the environment names with the names **you** used when running `conda env create -f envs/<name>.yaml` (see [Setup Clindet → Configure Environment Reuse](../Quick/install#configure-environment-reuse)). The default values above reflect the recommended naming convention, but if you named your environments differently, you must update them here accordingly.

If an environment name is left empty (e.g., `facets:` above), Snakemake will rebuild that environment from the corresponding `envs/*.yaml` file on every run.

## softwares_params.yaml

> **Expert users only.** This file records the runtime parameters, reference data paths, and configuration templates for every software tool in the workflow. Clindet ships with carefully tuned defaults based on software best practices and validated benchmark results. **If you have followed the standard setup instructions, do not modify this file** — the defaults will work for the vast majority of analyses.

The file is organized by genome version under the `softwares_params` key. Each tool's subsection contains its genome-specific reference files and runtime flags. A representative excerpt for `b37` is shown below:

```yaml
softwares_params:
  b37:
    star:
      index: "resources/ref_genome/b37/STAR/b37"
    rsem:
      index: "resources/ref_genome/b37/RSEM/b37"
    vcf2maf:
      build_version: "GRCh37"
      vep:
        vep_data: "resources/ref_genome/b37/vep"
        cache_version: "113"
        species: "homo_sapiens"
    caveman:
      ignorebed: "resources/ref_genome/b37/Sanger/cgpCaVEManWrapper_CPBI_refarea/hi_seq_depth.bed"
      flag:
        s: "HUMAN"
    sage:
      ref_genome_version: 37
      clinvar_annotations: "resources/ref_genome/b37/hmf_pipeline_resources/dna/variants/clinvar.37.vcf.gz"
```

The file configures the following tool groups, each under its genome version:

| Tool | What it configures |
|---|---|
| `star`, `salmon`, `kallisto`, `rsem` | Genome index paths for aligners and quantifiers |
| `vcf2maf`, `maf2vcf` | VEP cache path, species, and build version for variant annotation |
| `annotate_beds` | GIAB (Genome in a Bottle) confident/difficult region BEDs |
| `conpair` | Reference FASTA for concordance checking |
| `caveman`, `cgppindel`, `brass` | Sanger pipeline reference files and species flags |
| `ascat`, `ascat_wgs`, `freec`, `facets`, `sequenza` | CNV tool reference data and genome build |
| `arriba`, `gridss` | Fusion/SV tool databases and blacklists |
| `hmftools` | HMF pipeline resources — includes sub-configs for `amber`, `cobalt`, `purple`, `linx`, `sage`, `esvee`, `orange`, and others |
| `trust4` | Immune repertoire reference sequences |

These blocks are repeated for each supported genome (`b37`, `hg38`, `WBcel235`, `mm10`). If you add a custom genome to `genomes.yaml`, you must add a corresponding block here with the appropriate reference files for that genome version.
