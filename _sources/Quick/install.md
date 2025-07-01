(install)=

# Setup Clindet

## install conda, Docker and SingularityCE

To build the complex clindet analysis environment, you need install

## Install Clindet

### clone clindet from github

```bash
git clone  clindet.git
cd clindet
```
## Download and config Clindet pre-built singularity Image
### zendo

## Download and config Genome refernce file (eg, human b37)

clindet 参考GATK最佳实践的方法对测序fastq文件进行预处理。使用者可以从GATK的网站下载所需的文件，具体可参照[GATK Resource bundle](https://gatk.broadinstitute.org/hc/en-us/articles/360035890811-Resource-bundle)。包括fasta，GTF文件等。在clindet中，我们提供了人类基因组版本b37各文件的下载脚本用于自动下载，具体步骤如下：

### 软件安装

* **conda 环境 gsutils安装与配置**

```bash
conda env create -f env/gsutils.yaml
conda activate gsutils
```

* **conda 环境 clindet 安装与配置**

```bash
conda env create -f env/clindet.yaml
conda activate clindet
```

* **下载并安装GATK**

参照[GATK官网](https://github.com/broadinstitute/gatk)的说明进行GATK Toolkit的安装与配置，建议将该软件安装到家目录下的softwares文件夹中

* **下载并安装picard**

参照[picard官网](https://broadinstitute.github.io/picard/)进行picard软件的安装与配置

### download B37

On folder clindet, make a folder to store genome fastq and other files for b37

```bash
mkdir -p reference/human/b37
cd reference/human/b37
```

using following scripts to download files

```bash
gsutil -m cp -r \
  "gs://gcp-public-data--broad-references/hg19/v0/1000G_omni2.5.b37.vcf.gz" \
  "gs://gcp-public-data--broad-references/hg19/v0/1000G_omni2.5.b37.vcf.gz.tbi" \
  "gs://gcp-public-data--broad-references/hg19/v0/1000G_phase1.snps.high_confidence.b37.vcf.gz" \
  "gs://gcp-public-data--broad-references/hg19/v0/1000G_phase1.snps.high_confidence.b37.vcf.gz.tbi" \
  "gs://gcp-public-data--broad-references/hg19/v0/1000G_reference_panel" \
  "gs://gcp-public-data--broad-references/hg19/v0/Axiom_Exome_Plus.genotypes.all_populations.poly.vcf.gz" \
  "gs://gcp-public-data--broad-references/hg19/v0/Axiom_Exome_Plus.genotypes.all_populations.poly.vcf.gz.tbi" \
  "gs://gcp-public-data--broad-references/hg19/v0/ExomeContam.vcf" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.cdna.all.fa" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.cds.all.fa" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.cloud_references.json" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.contam.UD" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.contam.V" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.contam.bed" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.contam.mu" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.dbsnp138.vcf" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.dbsnp138.vcf.idx" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard0.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard1.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard10.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard11.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard2.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard3.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard4.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard5.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard6.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard7.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard8.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.delly_exclusionRegions.shard9.tsv" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.dict" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.64.amb" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.64.ann" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.64.bwt" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.64.pac" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.64.sa" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.alt" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.amb" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.ann" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.bwt" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.fai" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.pac" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.rbwt" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.rpac" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.rsa" \
  "gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.sa" \
  .

gsutil -m cp \
  "gs://gatk-best-practices/somatic-b37/Mutect2-WGS-panel-b37.vcf" \
  "gs://gatk-best-practices/somatic-b37/Mutect2-WGS-panel-b37.vcf.idx" \
  "gs://gatk-best-practices/somatic-b37/Mutect2-exome-panel.vcf" \
  "gs://gatk-best-practices/somatic-b37/Mutect2-exome-panel.vcf.idx" \
  .
  
  
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/Mills_and_1000G_gold_standard.indels.b37.vcf.gz.md5
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.indels.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.indels.b37.vcf.gz.md5
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.snps.high_confidence.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase1.snps.high_confidence.b37.vcf.gz.md5
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/hapmap_3.3.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/hapmap_3.3.b37.vcf.gz.md5
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_omni2.5.b37.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_omni2.5.b37.vcf.gz.md5
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase3_v4_20130502.sites.vcf.gz
wget -c ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/1000G_phase3_v4_20130502.sites.vcf.gz.md5

```

## Resource bundle

## edit config file

config文件主要用来包括三大部分参数的配置，可以在包括

* Resource
  用来记录各版本参考基因组的fasta, GTF，Panel of Normal文件的绝对路径信息
* softwares
  用来记录分析软件的绝对路径，conda环境，参数等信息
* singularity
  用来记录singularity封装容器的绝对路径与运行参数

以b37版本为例，在使用下载[下载脚本](#download B37)下载参考基因组后(也可以使用其他方法自行从GATK中下载)，首先需要在workflow/config文件夹中创建config.yaml文件（以该文件夹下的config_local_test.yaml作为模版)，在resource section进行如下配置：

```yaml
resources:
  b37:
    REFFA: "/Your_file_path/reference/b37/Homo_sapiens_assembly19.fasta"
    GENOME_BED: ""
    GTF: ""
    WES_PON: "/Your_file_path/reference/b37/Mutect2-exome-panel.vcf"
    WES_BED: ""
    WGS_PON: "/Your_file_path/reference/b37/Mutect2-WGS-panel-b37.vcf"
    DBSNP: "/Your_file_path/reference/b37/Homo_sapiens_assembly19.dbsnp138.vcf"
    DBSNP_GZ: "/Your_file_path/reference/b37/Homo_sapiens_assembly19.dbsnp138.vcf.gz"
    MUTECT2_VCF: "/Your_file_path/af-only-gnomad.raw.sites.b37.vcf.gz"
    REFFA_DICT: "/Your_file_path/reference/b37/Homo_sapiens_assembly19.fasta"
    MUTECT2_germline_vcf: "/Your_file_path/af-only-gnomad.raw.sites.b37.vcf.gz"
```

需将以上字段自行配置为下载后软件的位置

其中GTF可自行从[GeneCode](https://www.gencodegenes.org/human/release_46lift37.html)网站下载，但需要从GTF文件中去掉’chr' prefix。人类各版本基因组的不同可以参考[This Post](https://www.gencodegenes.org/human/release_46lift37.html).

GENOME_BED,与WES_BED主要用来记录染色体与基因外显子区间的坐标文件，可为空。

其余参数的具体说明可参考


