(install)=

# Setup Clindet

## Prerequisites

### System Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| Disk space | ~200 GB | 500 GB+ |
| RAM | 32 GB | 64 GB+ |
| CPU cores | 8 | 20+ |
| OS | Linux | Linux |

> **Disk space note:** The reference genome setup alone downloads approximately **170 GB** of files. Ensure you have sufficient free space before starting.

### Software

- **[Conda](https://docs.conda.io/en/latest/miniconda.html)** — environment and package management
- **[SingularityCE](https://sylabs.io/docs/)** — containerized tool execution
- **Git** — to clone the repository

Verify your installations:

```bash
conda --version
singularity --version
git --version
```

## Clone the Repository

```bash
git clone https://github.com/zyllifeworld/clindet.git
cd clindet
```

## Quick Test

The `mini_test_data/` folder contains a reduced dataset (chromosome 21 only) for a fast end-to-end test. Run this first to verify your environment is correctly configured before moving on to full-scale analyses.

> **Note:** Running Clindet requires reference annotation files (e.g., dbSNP, tool-specific configuration files) downloaded during the reference genome setup step below. The default configuration has been validated across a wide range of cancer datasets and handles cross-tool compatibility issues — such as chromosome naming conventions (`chr` prefix vs. no prefix in the reference FASTA). **Beginners should stick with the default setup.** Experienced users may customize as needed.

### Install the Conda Environment

```bash
conda env create -f envs/clindet.yaml
conda activate clindet
```

### Configure Environment Reuse

By default, Snakemake rebuilds Conda environments on every run. To install environments once and reuse them, first create all the required Conda environments:

```bash
conda env create -f envs/clindet.yaml
conda env create -f envs/rsem.yaml
conda env create -f envs/clindet_vep.yaml
conda env create -f envs/strelka.yaml
conda env create -f envs/hmftools.yaml
```

Then edit **`workflow/config/conf/softwares.yaml`** and set each tool to its installed environment name:

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

> **If you prefer Snakemake to rebuild environments on every run, leave all values above empty.**

### Pre-built Container Images

By default, Clindet pulls Singularity container images from Docker Hub at runtime. If your remote HPC has network access, you can pre-download all required images at once using the built-in `pull_zenodo` target:

```bash
snakemake \
  --config run_type=pull_zenodo \
  --cores 2 \
  --use-conda \
  --conda-frontend conda \
  --rerun-incomplete \
  --latency-wait 300 \
  --retries 3 \
  -n -p
```

If the HPC cannot access external networks, download the pre-built containers from a local machine with internet access at:

- [Zenodo](https://zenodo.org/records/20783116)
- [ScienceDB](https://www.scidb.cn/s/FRBb6n)

Then transfer the images via hard drive to the `clindet/resources/containers` folder on the HPC. Clindet will pick them up from this location automatically.

### Configure Temporary Directory

GATK tools can fail when the default temporary directory runs out of space. Set a custom `temp_directory` with sufficient disk space in **`workflow/config/conf/softwares.yaml`**:

```yaml
params:
  java:
    temp_directory: "/path/to/your/tmp"
```

### Configure Singularity Bind Path

When using Singularity, you must bind your home directory (or the directory containing your data and reference files) so the container can access them. The bind path is passed via `--singularity-args`:

```
--singularity-args "--bind /your/home/path:/your/home/path"
```

### Run the Quick Test

Replace `/your/home/path` below with your actual home directory, then choose the command for your data type:

```bash
# DNA (WES)
snakemake -c 20 --config run_type=wes \
    --configfile mini_test_data/dna/data/test_config.yaml \
    --rerun-triggers mtime --benchmark-extended \
    --use-singularity --singularity-args "--bind /your/home/path:/your/home/path" \
    --latency-wait 300 --use-conda --conda-frontend conda -k

# RNA
snakemake -c 20 --config run_type=rna \
    --configfile mini_test_data/rna/fusion/data/test_rna.yaml \
    --rerun-triggers mtime --benchmark-extended \
    --use-singularity --singularity-args "--bind /your/home/path:/your/home/path" \
    --latency-wait 300 --use-conda --conda-frontend conda -k
```

#### Expected Outputs

After a successful RNA run, the results directory should look like this:

```
mini_test/rna/hg38_chr21/results
├── benchmarks
│   └── fusion
│       ├── mini.star_arriba_map_1.benchmark.txt
│       └── mini.star_arriba_map.benchmark.txt
├── fusion
│   └── mini_arriba_fusion.tsv          # contains TMPRSS2-ERG fusion
└── mapped
    └── STAR
        └── mini
            ├── Aligned.out.bam
            ├── Log.final.out
            ├── Log.out
            ├── Log.progress.out
            ├── mini_pass1.log
            ├── mini.sorted.bam.bai
            ├── mini_star.log
            ├── mini_unmapped_R1.fq
            ├── mini_unmapped_R2.fq
            ├── SJ.out.tab
            └── _STARgenome/ ...
```

The key output file is `fusion/mini_arriba_fusion.tsv`, which should detect the **TMPRSS2-ERG** fusion — a known driver event in the test dataset.

> **If the quick test completes successfully,** proceed to the Reference Genome Setup below. Otherwise, double-check your Conda environment and Singularity bind path configuration.

### Note for Experienced Users

If you already have reference files (human genome FASTA, GTF, dbSNP, etc.) on your cluster, you can skip the download step and point directly to your existing files. Edit the reference paths under the `resources` section in your workflow config file (e.g., `workflow/config/config.yaml`). See [Configuring the Workflow](../Quick/config) for details.

## Reference Genome Setup

Once the quick test passes, download and configure the full human reference genome. The `run_type` parameter specifies which reference to build — `build_b37` downloads the human b37 (GRCh37) reference files including the genome FASTA, dbSNP, GTF annotation, and tool-specific resource files. This step downloads approximately **170 GB** of data, so ensure you have sufficient disk space before running the command below:

```bash
snakemake \
  --config run_type=build_b37 \
  --cores 2 \
  --use-conda \
  --conda-frontend conda \
  --rerun-incomplete \
  --latency-wait 300 \
  --retries 3 \
  -n -p
```

> **For the hg38 reference genome:** replace `run_type=build_b37` with `run_type=build_hg38` in the command above.

### Legacy Script (Deprecated)

The shell script `build_conda_envs.sh` is no longer recommended. It downloads the same ~170 GB of reference files but is not integrated with the current Snakemake workflow. Use `snakemake --config run_type=build_b37` instead.

### Generate a BED File for WES Analysis

Create a BED file from a GTF annotation to define exome capture regions. The BED file should contain four columns: **chr**, **start**, **end**, **gene_name** (*optional*). Example:

```text
1       11858   12237   DDX11L1
1       12602   12731   DDX11L1
1       12964   13062   DDX11L1
1       13210   14511   DDX11L1;WASH7P
```

ClinDet provides a [reference BED file](../usecase/b37_gene.bed) for the b37 genome (used in Use Case I). You can also generate your own using the provided script [`gtf2bed.R`](../utils/gtf2bed.R).

## Slurm Cluster Submission

To submit Clindet jobs to a Slurm-managed HPC cluster, edit **`workflow/config_slurm/config.v8+.yaml`** and update the `partition` parameter to match your cluster's partition name:

```yaml
default-resources:
  - partition=SVC   # change 'SVC' to your cluster's partition name
```

Run `sinfo` on the cluster to list available partitions. Replace `SVC` with the appropriate partition for your system.

## Next Steps

- [Configure your workflow parameters](../Quick/config) — set up `config.yaml` and `samples.tsv` for your project
- [Browse use cases](../usecase/index) — see real-world analysis examples
- [DNA-seq workflow details](../DNAseq/index) — in-depth documentation for DNA analysis
- [RNA-seq workflow details](../RNAseq/index) — in-depth documentation for RNA analysis
