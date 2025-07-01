# Call Mutation

For better reproducibility, Clindet [GATK best practice](https://gatk.broadinstitute.org/hc/en-us/sections/360007226651-Best-Practices-Workflows),[ICGC-TCGA-PanCancer project](https://github.com/ICGC-TCGA-PanCancer) data analysis workflow from three institutions (DKFZ, Sanger institute,Broad institute) and HMFtools from [Hartwig Medical Foundation](https://github.com/hartwigmedical/hmftools), upto 13 softwares to call somatic and germline mutations.Then,a custome R script were used to combine all results to get a consensus result.

Clindet provides two mutation detection modes for tumor samples: tumor-normal paired sample mode and tumor-only mode, to accommodate the testing needs of different clinical cohorts.

:::{table} Clindet WES mutation call module
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


:::{table} Table caption
:widths: auto
:align: center
| foo | bar |
| --- | --- |
| baz | bim |
:::

## Call Mutation from Different sortwares

````{tip}

You can set caller (support paired mode ) from Snakefile by set callers parameter(**only name in bellow list is accepted**):

   ```{code-block} python
   callers =  ['muse','caveman','cgppindel','sage','deepvariant','vardict','varscan','lofreq','StrelkaSomaticManta','mutect2','HaploCallers']

   ```
高通量测序技术的出现是过去几十年测序领域最重要的技术进步，这项技术极大地改变了生物学的研究范式，并极大地促进了人们对于疾病和健康的了解。

近十几年来，由于高通量测序的成本急速下降，为研究者们构建疾病大队列进行疾病发生发展机制的研究提供了丰富数据与新的研究机会，例如ICGC/TCGA Pan-Cancer Project，同时这些技术也广泛于临床检验，将疾病的诊断与治疗方案的带到了新的水平，为疾病的精准医疗提供了基础。然而，随着数据量的激增以及数据计算与存储依然高昂的成本，分析与存储这些数据的挑战也日益突出。准确的突变检验是所有下游分析的基础，因此高通量测序技术在临床检验与科学研究中的应用依然存在以下重要的issue：
1）数据分析的可重复性。高通量测序产生的数据往往复杂且庞大，分析过程中可能会收到各种因素的影响，如分析软件的选取、分析参数的选择等。因此确保分析的结果可重复需要建立标准化的分析流程以及标准的输出文件
2）分析过程的自动化、模块化是提高效率的关键，随着数据的激增，开发自动化的分析管道，可以将数据预处理、分析与结果可视化等步骤整合在一起，从而提高分析的效率和准确性。此外模块化分析可以使得研究人员根据不同需求选择不同的分析模块，灵活应对不同的分析需求。
3）单个方法的偏向性以及多个方法的整合，不同的分析软件由于算法模型不同，输出结果可能会存在偏差。因此，综合多种分析方法的结果，进行数据整合和交叉验证，可以提高结果的可靠性。这需要开发新的算法和工具，以便在不同的数据集和分析方法之间进行有效的整合。
4）临床样本质控问题同样重要，建立严格的质控标准和流程，确保样本的质量，是进行有效分析的前提。
虽然目前已经有大量的工具与流程用于高通量数据的分析，但这些数据分析流程并没有，如sarek与oncoanalysis。但目前仍然缺少工具可以解决以上所有问题，因此在本文中我们we present clindet, a sustainable and flexible data analysis workflow for clinical high throughout  sequencing data. 结合临床数据中常见的高通量数据，我们开发了三个sub-workflow：1）全外显子组分析流程：。2）全基因组分析流程：。3）转录组分析流程。Clindet可以完成突变检测、拷贝数变异检测、结构变异检测等任务，其中突变检测任务整合约13个软件的分析结果，拷贝数变异整合了，结构变异检测模块整合4个软件的分析结果，这些任务的整合结果均为标准输出文件（eg. VCF files , segment files)。对于临床检验的目的，我们对标准文件进行注释与，可生成病人的检查报告，对于科学研究目的，我们开发了Advanced 模块，可以对疾病队列数据进行进一步分析如驱动基因检测，recurrent copy number identition克隆演化分析等。
````

### GATK HaploCallers

### Mutect2
Mutect2 needs a panel of normal (PoN) sample VCF file to call somatic mutations.clindet supported two mode to do this analysis:
1) Call PoN VCF from cohort paried normal sample 
2) 
### Muse

### CaveMan
[CaVEMan](https://github.com/cancerit/CaVEMan) is a mutation caller developed by Wellcome Sanger institute. 

CaVEMan运行需要一些配置文件。可以从[cancerkit FTP](https://ftp.sanger.ac.uk/pub/cancer/dockstore/human/)处下载。此处以b37版本基因组(染色体名字不带有chr prefix)为例，下载SNV_INDEL_ref_GRCh37d5-fragment.tar.gz文件后解压，得到的文件树如下:

```bash
/SNV_INDEL_ref
├── caveman
│   ├── flagging
│   │   ├── centromeric_repeats.bed.gz
│   │   ├── centromeric_repeats.bed.gz.tbi
│   │   ├── flag.to.vcf.convert.ini
│   │   ├── flag.vcf.config.ini
│   │   ├── gene_regions.bed.gz
│   │   ├── gene_regions.bed.gz.tbi
│   │   ├── hg19_codingexon_regions.indel.bed.gz
│   │   ├── hg19_codingexon_regions.indel.bed.gz.tbi
│   │   ├── hg19_gene_regions.bed.gz
│   │   ├── hg19_gene_regions.bed.gz.tbi
│   │   ├── hi_seq_depth.bed.gz
│   │   ├── hi_seq_depth.bed.gz.tbi
│   │   ├── simple_repeats.bed.gz
│   │   ├── simple_repeats.bed.gz.tbi
│   │   ├── snps.bed.gz
│   │   ├── snps.bed.gz.tbi
│   │   ├── unmatchedNormal.bed.gz
│   │   └── unmatchedNormal.bed.gz.tbi
│   ├── flag.vcf.config.WGS.ini
│   ├── flag.vcf.config.WXS.ini
│   ├── HiDepth.tsv
│   ├── unmatchedNormal.bed.gz
│   └── unmatchedNormal.bed.gz.tbi
└── pindel
    ├── HiDepth.bed.gz
    ├── HiDepth.bed.gz.tbi
    ├── pindel_np.gff3.gz
    ├── pindel_np.gff3.gz.tbi
    ├── simpleRepeats.bed.gz
    ├── simpleRepeats.bed.gz.tbi
    ├── softRules.lst
    ├── WGS_Rules.lst
    └── WXS_Rules.lst
```

之后在config.yaml文件中的software章节配置如下参数(文件的绝对路径):

::::{tab-set}


:::{tab-item} b37
```yaml
   caveman:
      sif: "/public/ClinicalExam/lj_sih/softwares/caveman153.sif"
      cpu: 30
      ignorebed: "/public/ClinicalExam/lj_sih/projects/project_pipeline/WES/hg19_ignore-region-exon.bed"
      b37:
      flag:
         c: "/Your/Path/SNV_INDEL_ref/caveman/flagging/flag.vcf.config.ini"
         v: "/Your/Path/SNV_INDEL_ref/caveman/flagging/flag.to.vcf.convert.ini"
         u: "/Your/Path/SNV_INDEL_ref/caveman/flagging"
         g: "/Your/Path/SNV_INDEL_ref/caveman/flagging/germline.bed.gz"
         b: "/Your/Path/SNV_INDEL_ref/caveman/flagging/caveman"
         ab: "/Your/Path/SNV_INDEL_ref/caveman/flagging"
```
:::

:::{tab-item} hg19
```yaml
   caveman:
      sif: "/public/ClinicalExam/lj_sih/softwares/caveman153.sif"
      cpu: 30
      ignorebed: "/public/ClinicalExam/lj_sih/projects/project_pipeline/WES/hg19_ignore-region-exon.bed"
      hg19:
      flag:
         c: "/Your/Path/SNV_INDEL_ref/hg19/caveman/flagging/flag.vcf.config.ini"
         v: "/Your/Path/SNV_INDEL_ref/hg19/caveman/flagging/flag.to.vcf.convert.ini"
         u: "/Your/Path/SNV_INDEL_ref/hg19/caveman/flagging"
         g: "/Your/Path/SNV_INDEL_ref/hg19/caveman/flagging/germline.bed.gz"
         b: "/Your/Path/SNV_INDEL_ref/hg19/caveman/flagging/caveman"
         ab: "/Your/Path/SNV_INDEL_ref/hg19/caveman/flagging"
```
:::

::::





如果你想使用包含chr版本(eg. hg19),则需要将flagging文件下的bed文件在染色体名字中添加chr prefix


原始版本的CaVEMan不支持基因组中染色体名字含有'chr'前缀的

````{note}
**CaVEMan** rule flowchart
:::{dropdown} Tumor normal paired
```{mermaid}
    :align: center
    %%{init: {'theme': 'base', 'themeVariables': { 'fontSize': '{{ rule_fontsize }}'; } } }%%
    flowchart TD
        T@{ shape: circle, label: T} --> rule@{ shape: hex, label: "FreeC" }
        NC@{ shape: circle, label: NC} --> rule@{ shape: hex, label: "FreeC" }
        CNV@{ shape: hex, label: CNV result from ASCAT} --> rule@{ shape: hex, label: "CaVEMan" }

        rule --> ratio[*_ratios.txt]:::output
        rule --> mut[*_CNV.txt]:::output

        style T fill:#eb8509,stroke:#333,stroke-width:1px;
        style NC fill:#038c4a,stroke:#f66,stroke-width:1px,color:#fff,font-size:8pt,stroke-dasharray: 5 5
        style CNV stroke:#f66,stroke-width:1px,font-size:8pt,stroke-dasharray: 5 5

        style rule fill:#eb2409,font-size:8pt
        
        classDef Input fill:#038c4a,stroke:#333,stroke-width:4px;
        classDef software fill:#eb2409,stroke:#333,stroke-width:1px,shape:hex,font-size:8pt;
        classDef output stroke:#00f,font-size:8pt;
```
:::

:::{dropdown} Tumor only
```{mermaid}
    :align: center
    %%{init: {'theme': 'base', 'themeVariables': { 'fontSize': '{{ rule_fontsize }}'; } } }%%
    flowchart TD
        T@{ shape: circle, label: T} --> rule@{ shape: hex, label: "FreeC" }
        CNV@{ shape: hex, label: CNV result from ASCAT} --> rule@{ shape: hex, label: "CaVEMan" }

        rule --> ratio[*_ratios.txt]:::output
        rule --> mut[*_CNV.txt]:::output

        style T fill:#eb8509,stroke:#333,stroke-width:1px;stroke-dasharray: 5 5
        style CNV stroke:#f66,stroke-width:1px,font-size:8pt,stroke-dasharray: 5 5

        style rule fill:#eb2409,font-size:8pt
        
        classDef Input fill:#038c4a,stroke:#333,stroke-width:4px;
        classDef software fill:#eb2409,stroke:#333,stroke-width:1px,shape:hex,font-size:8pt;
        classDef output stroke:#00f,font-size:8pt;
```
:::

````

```{error}
Here is [markdown link syntax](https://jupyter.org)
```

````{note}
The warning block will be properly-parsed

   ```{warning}
   Here's my warning
   ```

But the next block will be parsed as raw text

    ```{warning}
    Here's my raw text warning that isn't parsed...
    ```

   ```{warning}
    Here's my raw text warning that isn't parsed...
   ```
````

## Annotation variants

## consensus result from multiple callers

## Output file types 