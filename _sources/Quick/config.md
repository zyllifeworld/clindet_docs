# Configuring the workflow

Running the workflow requires configuring two files: config.yaml, samples.tsv. config.yaml is used to configure the analyses, samples.tsv categorizes your samples into groups. The workflow will use config/config.yaml automatically, but it can be good to name it something informative and point to it when running snakemake with --configfile <path>.

There is a config template in config folder, You can modif 

## Software Configuration

This section contains the specific settings for each software, allowing users to customize the settings used. The default configuration file contains settings that are commonly used, and should be applicable to most datasets sequenced on patterened flow cells, but please check that they make sense for your analysis. If you are missing a configurable setting you need, open up an issue or a pull request and I'll gladly put it in if possible.

## Reference Configuration

本节将会介绍如何设置基因组相关参数，以人类b37版本为例。其中需要设置的参数为


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



```{code-block} python
---
lineno-start: 10
emphasize-lines: 1, 3
caption: |
    This is my
    multi-line caption. It is *pretty nifty* ;-)
---
a = 2
print('my 1st line')
print(f'my {a}nd line')
```