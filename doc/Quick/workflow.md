# clindet workflow

- [clindet workflow](#clindet-workflow)
  - [Small variants (SNVs/Indels) (Somatic)](#small-variants-snvsindels-somatic)
    - [Summary](#summary)
    - [Details](#details)
  - [SNPs and small indels (Germline)](#snps-and-small-indels-germline)
  - [Structural variants](#structural-variants)
  - [Copy Number Variants](#copy-number-variants)
  - [Transcriptom analysis](#rna-seq)
  - [MultiQC](#multiqc)
  - [Coverage](#coverage)
  - [Reports](#reports)
  - [Key Cancer genes](#key-cancer-genes)
  - [Snakemake Rules](#snakemake-rules)
    - [`somatic.smk`](#somaticsmk)
    - [`pcgr.smk`](#pcgrsmk)
    - [`structural.smk`](#structuralsmk)
    - [`oncoviruses.smk`](#oncovirusessmk)
      - [oviraptor - https://github.com/umccr/oviraptor](#oviraptor---httpsgithubcomumccroviraptor)

clindet post-processess outputs of cancer variant calling analysis pipelines
from **BAM** from Tumor-Normal paired (Tumor-only model)
and generates reports for researchers and curators at UMCCR.

It takes as input results from the UMCCR DRAGEN Tumor/Normal and DRAGEN Germline
variant calling workflows:

- BAM files from both samples
- somatic small variant calls
- germline small variant calls
- somatic structural variant calls

## Small variants (SNVs/Indels) (Somatic)

This part of the workflow filters and prioritises small somatic variant calls.
The idea of filtering is to remove most of the artefacts and germline leakage,
but at the same time to be permissive towards known clinically important sites
even if the variants are of low quality.

### Summary

1. **Call** candidate variants using multiple softwares.
2. **Keep** variants that pass DRAGEN's default quality control thresholds.
3. **Keep** variants that are in the auto/sex/mito chromosomes (1-22, X, Y, M).
4. **Rescue** variants that are in hotspot sites according to SAGE.
5. **Annotate** variants with info from databases/files.
6. If the sample is **hypermutated** (i.e. has > 500K variants):
   - **remove** non-hotspot variants with `gnomad_AF >= 0.01`
   - **remove** variants not overlapping gene regions (specified in a BED file)
7. **Filter** variants based on certain thresholds, for example:
   - **Keep** those with PCGR **Tiers 1/2**, known **hotspots**
   - **Dump** those with **low AF** (`TUMOR_AF < 0.1`)

### Details

Steps are:

1. Extract passing calls (with `PASS` in FILTER)
2. Extract calls on main chromosomes (chr1-chr22, chrX, chrY, chrM)
3. Run
   [SAGE v1.0](https://github.com/hartwigmedical/hmftools/tree/sage-v1.0/sage)
   and add the result to the VCF. SAGE is a low-frequency variant caller with a
   high precision, created by Hartwig Medical Foundation. Instead of the whole
   genome, it targets only coding regions for inframe indels, and
   [known hotspot sites](https://raw.githubusercontent.com/umccr/workflows/master/genes/hotspots/hotspots.tsv)
   from the following list:
   - [Cancer Genome Interpreter](https://www.cancergenomeinterpreter.org/home)
   - [CIViC](http://civic.genome.wustl.edu/) - Clinical interpretations of
     variants in cancer
   - [OncoKB](https://oncokb.org/) - Precision Oncology Knowledge Base
4. Annotate the VCF against the reference sources:
   - High-confidence regions from the Genome in a Bottle benchmark;
   - [GnomAD](https://gnomad.broadinstitute.org) whole genome "common" variants
     (max population frequency > 1%);
   - Low complexity regions (LCR):
     - Homopolymers, STRs, VNTRs and other repetitive sequences,
       [compiled from TRDB](https://github.com/ga4gh/benchmarking-tools/blob/master/resources/stratification-bed-files/LowComplexity/TRDB_processing.sh),
     - Regions compiled by Heng Li from 3 separate masks: low-complexity regions
       by mDUST and from UCSC repeatMasker plus flanking regions, structural
       mask (HWE+depth mask from 1000g plus flanking regions), and 75bp
       mappability mask.
   - Low and high-GC regions (regions < 30% or > 65% GC content),
     [compiled by GA4GH](https://github.com/ga4gh/benchmarking-tools/tree/master/resources/stratification-bed-files/GCcontent)
   - Bad promoter regions
     ([compiled by GA4GH](https://github.com/ga4gh/benchmarking-tools/tree/master/resources/stratification-bed-files/FunctionalTechnicallyDifficultRegions):
     "Anecdotal results suggested that many transcription start sites or first
     exons in the human genome tend to have poor coverage. By a systematic
     analysis of these regions we defined the 1,000 with the lowest relative
     coverage based on low coverage by an Illumina data set, which we term the
     'bad promoters' list. The bad promoters are, like many exons, GC-rich,
     averaging 79% GC composition");
   - [ENCODE blacklist](https://github.com/Boyle-Lab/Blacklist);
   - Segmental duplication regions (UCSC);
   - UMCCR
     [panel of normals](https://github.com/umccr/vcf_stuff/blob/master/vcf_stuff/panel_of_normals/story/panel_of_normals.md),
     build from tumor-only mutect2 calls from ~200 normal samples.
5. If after removing non-hotspot GnomAD variants there are still > 500k somatic
   variants left flag the sample as highly mutated (or FFPE) and limit all calls
   to to cancer genes only (to avoid downstream R performance problems).
6. Standardise the VCF fields: add new `INFO` fields `TUMOR_AF`, `NORMAL_AF`,
   `TUMOR_DP`, `NORMAL_DP`, `TUMOR_VD`, `NORMAL_VD` (for use with PCGR), and
   `AD FORMAT` field (for use with PURPLE).
7. Run [PCGR](https://github.com/sigven/pcgr) to annotate VCF against the
   external sources, and classify by tiers based on annotations and functional
   impact. At the end, this step adds `INFO` fields into the VCF: `TIER`,
   `SYMBOL`, `CONSEQUENCE`, `MUTATION_HOTSPOT`, `INTOGEN_DRIVER_MUT`,
   `TCGA_PANCANCER_COUNT`, `CLINVAR_CLNSIG`, `ICGC_PCAWG_HITS`, `COSMIC_CNT`.
   The list of external sources used at this step is:
   - [VEP](http://www.ensembl.org/info/docs/tools/vep/index.html) to infer the
     functional impact
   - TCGA and ICGC recurrent variants
   - [Open Targets Platform](https://targetvalidation.org/)
   - [ClinVar](http://www.ncbi.nlm.nih.gov/clinvar/) - Database of variants with
     clinical significance
   - [CancerMine](https://zenodo.org/record/2662509#.XM0xMdMzaL4) -
     Literature-derived database of tumor suppressor genes/proto-oncogenes
   - [DoCM](http://docm.genome.wustl.edu) - Database of curated mutations
   - [CBMDB](http://www.cancergenomeinterpreter.org/biomarkers) - Cancer
     Biomarkers database
   - [DisGeNET](http://www.disgenet.org) - Database of gene-tumor type
     associations
   - [Cancer Hotspots](http://cancerhotspots.org) - Resource for statistically
     significant mutations in cancer
   - [dBNSFP](https://sites.google.com/site/jpopgen/dbNSFP) - Database of
     non-synonymous functional predictions
   - [UniProt/SwissProt KnowledgeBase](http://www.uniprot.org) - Resource on
     protein sequence and functional information
   - [Pfam](http://pfam.xfam.org) - Database of protein families and domains
   - [DGIdb](http://dgidb.genome.wustl.edu) - Database of targeted cancer drugs
   - [ChEMBL](https://www.ebi.ac.uk/chembl/) - Manually curated database of
     bioactive molecules
8. [Filter variants](https://github.com/umccr/vcf_stuff/blob/master/scripts/filter_somatic_vcf)
   to remove putative germline variants and artefacts, but make sure to keep
   known hotspots/actionable variants:
   - Keep variants called by SAGE in known hotspots (CGI, CiViC, OncoKB)
     regardless of other evidence;
   - Keep variants PCGR TIER 1 and 2 (strong and potential clinical
     significance, according to
     [ACMG](https://www.ncbi.nlm.nih.gov/pubmed/27993330) standard guidelines)
     regardless of other evidence;
   - Keep all driver mutations ([Intogen](https://www.intogen.org/));
     [mutation hotspots](http://cancerhotspots.org/]);
     [ClinVar](https://www.ncbi.nlm.nih.gov/clinvar/) pathogenic or uncertain
     (to include the mixed evidence); COSMIC count >=10; TCGA pancancer
     count >=5; ICGC PCAWG count >= 3 (all annotated by PCGR), regardless of
     other evidence;
   - For all other variants, apply the following LCR, PoN, depth and AF filters.
     Remove variants for which one or more of the following conditions apply:
     - `AF<10%`,
     - Common variant in GnomAD (max `population AF>=1%`), add into the germline
       set (see below);
     - Present in >=5 samples of the Panel of Normal set;
     - InDel in a "bad promoter" regions (GA4GH: "Anecdotal results suggested
       that many transcription start sites or first exons in the human genome
       tend to have poor coverage. By a systematic analysis of these regions we
       defined the 1,000 with the lowest relative coverage based on low coverage
       by an Illumina data set, which we term the 'bad promoters' list. The bad
       promoters are, like many exons, GC-rich, averaging 79% GC composition);
     - Overlapping the
       [ENCODE blacklist](https://github.com/Boyle-Lab/Blacklist),
     - Variant depth `VD<4`;
     - Variant depth `VD<6`, and the variant overlaps a low complexity region
       (see step 4 above);
     - VarDict strand-biased variants (single strand support for ALT, while REF
       has both; or REF and ALT have opposite supporting strands), unless
       supported by all other callers.
9. Report passing variants using [PCGR](https://github.com/sigven/pcgr),
   classified by the ACMG tier system.

## SNPs and small indels (Germline)

The idea is to simply bring germline variants in cancer predisposition genes:

1. Take passing "ensemble" germline VCF from
   [bcbio](https://github.com/umccr/workflows/tree/master/bcbio). "Ensemble" has
   variants supported by at least 2 of 3 callers (we use strelka2, vardict, and
   GATK Haplotype Caller).
2. Add back variants from somatic calling filtered as common GnomAD.
3. Subset variants to a list of ~200 cancer predisposition genes, which is build
   by [CPSR](https://github.com/sigven/cpsr) from 3 curated sources:
   [TCGA](https://www.ncbi.nlm.nih.gov/pubmed/29625052) pan-cancer study,
   [COSMIC CGC](https://cancer.sanger.ac.uk/census), and
   [Norwegian Cancer Genomics Consortium](http://cancergenomics.no/).
4. Report variants using [CPSR](https://github.com/sigven/cpsr), which
   classifies variants in the context of cancer predisposition by overlapping
   with [ClinVar](https://www.ncbi.nlm.nih.gov/clinvar/) pathogenic and VUS
   variants and GnomAD rare variants. It also ranks variants according
   pathogenicity score by ACMG and cancer-specific criteria. When a variant is
   annotated as having multiple functional depending on a context of a gene and
   a trascript, a higher impact events are prioritised, and if all things equal,
   [APPRIS principal transcripts](http://appris.bioinfo.cnio.es/#/) are
   preferred. In any case, one event per variant is reported. Events are
   reported in 4 tiers according to their significance:
   - ClinVar variants: pre-classified variants according to a five-level tier
     scheme (Pathogenic to Benign):
   - Non-ClinVar variants: classified by CPSR according to a five-level tier
     scheme (Pathogenic to Benign)
   - Secondary findings (optional) - pathogenic ClinVar variants in the ACMG
     recommended list for reporting of incidental findings,
   - GWAS hits (optional) - variants overlapping with previously identified hits
     in genome-wide association studies (GWAS) of cancer phenotypes (i.e. low to
     moderate risk conferring alleles), using NHGRI-EBI Catalog of published
     genome-wide association studies as the underlying source. The unclassified
     non-ClinVar variants are assigned a pathogenicity level based on the
     aggregation of scores according to previously established ACMG criteria.
     The ACMG criteria includes cancer-specific criteria, as outlined and
     specified in several previous studies.

## Structural variants

The idea is to report gene fusions, exon deletions, high impact and LoF events
in tumor suppressors, and prioritise events in cancer genes.

1. Start with the somatic SV VCF from DRAGEN (called internally by a private
   [Manta](https://github.com/illumina/manta) version). Keep only PASS variants.
2. Annotate variants:
   - with [SnpEff](https://github.com/pcingola/SnpEff).
   - with [VEP](https://github.com/Ensembl/ensembl-vep)
   - Use the Ensembl gene model and
     [Sequence ontology](http://www.sequenceontology.org) terminology.
   - Subset annotations to
     [APPRIS principal transcripts](http://appris.bioinfo.cnio.es/#/), keeping
     one main isoform per gene.
3. Prioritise variants with
   <https://github.com/umccr/vcf_stuff/blob/master/scripts/prioritize_sv>. on a
   4 tier system - 1 (high) - 2 (moderate) - 3 (low) - 4 (no interest):
   - exon loss
     - on cancer gene list (1)
     - other (2)
   - gene fusion
     - paired (hits two genes)
       - on list of known pairs (1) (curated by
         [HMF](https://resources.hartwigmedicalfoundation.nl))
       - one gene is a known promiscuous fusion gene (1) (curated by
         [HMF](https://resources.hartwigmedicalfoundation.nl))
       - on list of
         [FusionCatcher](https://github.com/ndaniel/fusioncatcher/blob/master/bin/generate_known.py)
         known pairs (2)
       - other:
         - one or two genes on cancer gene list (2)
         - neither gene on cancer gene list (3)
     - unpaired (hits one gene)
       - on cancer gene list (2)
       - others (3)
   - upstream or downstream (a specific type of fusion, e.g. one gene is got
     into control of another gene's promoter and get over-expressed (oncogene)
     or underexpressed (tsgene))
     - on cancer gene list genes (2)
   - LoF or HIGH impact in a tumor suppressor
     - on cancer gene list (2)
     - other TS gene (3)
   - other (4)
4. If the number of events is over 50K (e.g. FFPE), progressively remove TIER
   4/3/2 SVs (in that order).
5. Refine SVs using Hartwig's
   [break-point-inspector](https://github.com/hartwigmedical/hmftools/tree/bpi-v1.5/break-point-inspector),
   which locally re-assembles SV loci to get more accurate breakpoint positions
   and AF estimates.
6. Filter low-quality calls:
   - keep PASS FILTER
   - dump TIER 3/4 where `SR < 5 & PR < 5`
   - dump TIER 3/4 where `SR < 10 & PR < 10 & (AF0 < 0.1 | AF1 < 0.1)`
7. Use filtered variants as a guidance for PURPLE CNV calling (see below).
   PURPLE will adjust and recover breakpoints at copy number transitions, and
   adjust AF based on copy number, purity and ploidy.
8. Run <https://github.com/umccr/vcf_stuff/blob/master/scripts/prioritize_sv> on
   the PURPLE output SVs.
9. Report tiered variants in the UMCCR cancer report.

## Copy Number Variants

The idea is to report significant CNV changes in key cancer genes and
disruptions in tumor suppressors. And also calculate sample purity and ploidy
profile.

We almost entirely rely on Hartwig's
[PURPLE](https://github.com/hartwigmedical/hmftools/tree/master/purity-ploidy-estimator)
workflow in this step. The PURPLE pipeline outlines as follows:

- Calculate B-allele frequencies (BAF) using AMBER subworkflow,
- Calculate read depth ratios using COBALT subworkflow,
- Perform segmentation (uses structural variant breakpoints for better
  guidance),
- Estimate the purity and copy number profile (uses somatic variants for better
  fitting),
- Plot a circos plot that visualises the CN/ploidy profile, as well as somatic
  variants, SVs, and BAFs,
- Rescue structural variants in copy number transitions and filter single
  breakends,
- Estimate overall tumor samples purity range,
- Determine gender,
- Report QC status of the sample, that will fail if the structural variants do
  not correspond to CN transitions, and gender is inconsistently called from
  BAFs and from the coverage.

From the PURPLE output, we report in the cancer report:

- Circos plot
- Minimal and maximal copy numbers in key cancer genes, that indicate
  amplifications/deletions as well as CN transitions that should match SVs
- QC status
- We also use Purity to adjust coverage reporting thresholds.
- Genome-wide CNV segments with breakpoint information. Includes segment CN,
  minor/major allele ploidy, type of SV support at start/end of segment, CN
  determination method, BAF/BAF count, GC%, Cobalt window coverage


## RNA-seq



## MultiQC

MultiQC aggregates QC from different tools. We report the following:

- Sample contamination level (for both tumor and normal) and T/N concordance (by
  [Conpair](https://github.com/nygenome/Conpair)),
- Ancestry and sex (by [Peddy](https://github.com/brentp/peddy)),
- Mapping QC: the number of mapped reads, paired reads, secondary or duplicated
  alignments, average coverage (using samtools stats and mosdepth in bcbio),
- Viral content and integration sites
  ([oncoviruses](https://github.com/umccr/oncoviruses)),
- PURPLE stats: QC, sex, purity/ploidy, TMB and MSI statuses
- Number of pre- and post-filtered SNPs and indels (by clindet) which indicates
  germline leakage,
- Coverage profile by goleft,
- Variants QC for filtered germline and somatic variants (by bcftools),
- Reads QC (by FastQC).

We also include reference "good" samples in the background for comparison.

## Coverage

The idea is to see if we can miss variants due to abnormal coverage (e.g.
because of copy numbers or abnormal GC).

- Run [`goleft indexcov`](https://github.com/brentp/goleft/tree/master/indexcov)
  to plot fast global coverage overview from a BAM or CRAM index.
- Run [`mosdepth`](https://github.com/brentp/mosdepth) to calculate quantized
  coverage in exons of cancer genes if interest, using 4 groups for
  quantization: NO_COVERAGE, LOW_COVERAGE, CALLABLE, HIGH_COVERAGE. For tumor,
  the thresholds are adjusted by average purity (as reported by PURPLE). The low
  coverage threshold is 12x divided by purity (the minimal coverage to call a
  pure heterozugous variant), the high coverage threshold is 100 divided by
  purity (suspiciously high coverage, might indicate an LCR, a repeat, or a CN).
- Run [CACAO](https://github.com/sigven/cacao) using the same thresholds to
  calculate coverage in loci of interest. For germline variants, use
  [ClinVar](https://www.ncbi.nlm.nih.gov/clinvar) predisposition variants. For
  somatic variants, use [CiViC](https://civicdb.org/) actionable variants and
  [cancerhotspots.org](https://www.cancerhotspots.org/) somatic hotspots. This
  step generates two HTML reports (one for somatic, one for germline variants).

## Reports

clindet produces 6 reports:

- [PCGR](https://github.com/sigven/pcgr) containing small somatic variants (SNPs
  and indels) classified according to
  [ACMG](https://www.ncbi.nlm.nih.gov/pubmed/27993330) guidelines, and MSI
  status of the sample.
- [CPSR](https://github.com/sigven/cpsr) containing small germline variants
  (SNPs and indels) in cancer predisposition genes, ranked by ACMG guidelines
  and cancer-specific criteria.
- [CACAO](https://github.com/sigven/cacao) for tumor sample, reporting coverage
  for clinically actionable and pathogenic loci in cancer
- CACAO for normal sample, reporting coverage in likely pathogenic variants
  cancer predisposition protein-coding genes
- [MultiQC](https://multiqc.info) report with QC stats and plots
- UMCCR cancer report containing:
  - Somatic mutation profile (global and in cancer genes),
  - Mutational signatures (by the MutationalPatterns R package),
  - Structural variants,
  - Copy number variants,
  - PURPLE QC status,
  - Circos plot,
  - Oncoviral content and integration sites.

## Key cancer genes

For reporting and variant prioritization, we prepared a
[UMCCR cancer key genes set](https://github.com/vladsaveliev/NGS_Utils/blob/master/ngs_utils/reference_data/key_genes/make_umccr_cancer_genes.Rmd).
It has been built off several sources:

- Cancermine with at least 2 publication with at least 3 citations,
- NCG known cancer genes,
- Tier 1 COSMIC Cancer Gene Census (CGC),
- CACAO hotspot genes (curated from ClinVar, CiViC, cancerhotspots),
- At least 2 matches in the following 5 sources and 8 clinical panels:
  - Cancer predisposition genes (CPSR list)
  - COSMIC Cancer Gene Census (tier 2)
  - AZ300
  - Familial Cancer
  - OncoKB annotated
  - MSKC-IMPACT
  - MSKC-Heme
  - PMCC-CCP
  - Illumina-TS500
  - TEMPUS
  - Foundation One
  - Foundation Heme
  - Vogelstein

The result is a list of 1248 genes.

## Snakemake Rules

### `somatic.smk`

1. `run_sage`

   - Runs `sage-2.2.jar` (jar included). Don't actually think this gets run by
     default, probably was used in a project-specific context.
   - input: BAMs (T/N), `hotspots_vcf`, `coding_bed`, `high_conf_bed`
   - output: `work/{batch}/small_variants/sage2/{batch}.vcf.gz`

2. `somatic_vcf_pass_sort`

   - Filters to only PASS and sorts
   - input: `batch_by_name[wc.batch].somatic_vcf` **or** above output VCF
   - output: `work/{batch}/small_variants/pass_sort/{batch}-somatic.vcf.gz`

3. `somatic_vcf_select_noalt`

   - Filters to variants within noalt regions (chr1-chr22, chrX, chrY, chrM)
   - input: above output VCF, `noalts_bed`
   - output: `work/{batch}/small_variants/noalt/{batch}-somatic.vcf.gz`

4. `somatic_vcf_sage1`

   - Runs `sage v1.0`
     - sage script:
       <https://github.com/umccr/vcf_stuff/blob/master/scripts/sage>
     - sage Snakemake subworkflow:
       <https://github.com/umccr/vcf_stuff/blob/master/vcf_stuff/filtering/sage.smk>
     - jar:
       <https://github.com/umccr/vcf_stuff/blob/master/vcf_stuff/filtering/sage-1.0.jar>
   - input: above output (noalt) VCF, BAMs (T/N)
   - output:
     - `work/{batch}/small_variants/sage1/{batch}-somatic.vcf.gz`
     - `{batch}/small_variants/sage1/{batch}-sage.vcf.gz`
     - Snakemake subworkflow:
       - `run_sage`
         - sage v1.0 with T/N BAMs, hotspots, coding regions,
         - output: `work/call/{SAMPLE}-sage.vcf.gz`
       - `sage_rename_anno`
         - sed `HOTSPOT -> SAGE_HOTSPOT`
         - output: `work/rename_anno/{SAMPLE}-sage.vcf.gz`
       - `sage_reorder_samples`
         - reorder samples, tumor first
         - output: `work/sage_reorder_samples/{SAMPLE}-sage.vcf.gz` (**final
           Sage VCF**)
       - `sage_pass`
         - keep PASS
         - output: `work/sage_pass/{SAMPLE}-sage.vcf.gz`
       - `sage_pass_novel`
         - intersect Sage PASS VCF with noalt VCF, keep only those 'novel'
           variants found in Sage
         - output: `work/sage_pass_novel/{SAMPLE}-sage.vcf.gz`
       - `add_novel_sage_calls`
         - concatenate above 'novel' with noalt VCF
         - output: `work/add_novel_sage_calls/{SAMPLE}.vcf.gz`
       - `sort_saged`
         - sort above
         - output: `work/sort_saged/{SAMPLE}.vcf.gz`
       - `annotate_from_sage`
         - input: above output VCF 'vcf' and final Sage VCF ('sage')
         - output: `work/annotate_from_sage/{SAMPLE}.vcf.gz`
         - iterate through 'sage' variants and create a `sage_calls` dict with
           chr/pos/ref/alt keys and the cyvcf2 record as values, then for 'vcf'
           variants that are PASSed, annotate 'SAGE_HOTSPOT' and use a 'PASS'
           FILTER, else use the 'SAGE_lowconf' FILTER tag. Then set the
           `FORMAT/DP` and `FORMAT/AD` based on the 'sage' call. Something like
           that.
       - `copy_result`
         - copy above output VCF to
           `work/{batch}/small_variants/sage1/{batch}-somatic.vcf.gz`
       - `sage`
         - copy `work/call/{SAMPLE}-sage.vcf.gz` to
           `{batch}/small_variants/sage1/{batch}-sage.vcf.gz`

5. `somatic_vcf_annotate`

   - input: above (work) output file **if**
     `batch_by_name[wc.batch].somatic_vcf`, **else** the `noalt`
   - output:

     - `work/{batch}/small_variants/annotate/{batch}-somatic.vcf.gz`
     - `work/{batch}/small_variants/somatic_anno/subset_highly_mutated_stats.yaml`

   - Runs `anno_somatic_vcf` from `vcf_stuff`

     - <https://github.com/umccr/vcf_stuff/blob/master/scripts/anno_somatic_vcf>
     - <https://github.com/umccr/vcf_stuff/blob/master/vcf_stuff/filtering/annotate_somatic_vcf.smk>
     - Snakemake subworkflow:
       - `prep_hmf_hotspots`
         - Filters HMF hotspots file from 17,875 in total down to 10,209 HMF
           variants
         - input: `hotspots` reference file
         - output: `somatic_anno/hmf_hotspot.vcf.gz`
       - `prep_anno_toml`
         - Prepares TOML file for use with vcfanno
         - input: lots of reference files
         - output: `somatic_anno/tricky_vcfanno.toml`
       - `somatic_vcf_regions_anno`
         - Runs vcfanno
         - input: TOML from above and the original (`sage1`) input VCF
         - output: `somatic_anno/vcfanno/{SAMPLE}-somatic.vcf.gz`
       - `maybe_subset_highly_mutated`
         - input: above output vcfanno'd VCF
         - output: `somatic_anno/subset/{SAMPLE}-somatic.vcf.gz`, `stats.yaml`
         - Count total vars
           - If that's `<= 500K`, all good, just copy that to the next step
           - If that's `> 500K`:
             - grab the `INFO/gnomad_AF` field
               - if that exists, is `>= 0.01`, and is not a HMF/SAGE HOTSPOT,
                 discard it
         - Write the count stats into the yaml output
       - `somatic_vcf_clean_info`
         - input: above output subset VCF
         - output: `somatic_anno/clean_info/{SAMPLE}-somatic.vcf.gz`
         - process:
           - Add a `TRICKY` INFO field in the VCF metadata (`proc_hdr` func)
           - Remove `TRICKY_*` and `ANN` fields from VCF metadata
             (`postproc_hdr` func)
           - Remove `ANN` and `TRICKY_*` INFO fields from variants, but join the
             `TRICKY_*` fields into a single pipe separated field under
             `INFO/TRICKY`.
           - This basically reduces the VCF size substantially.
       - `somatic_vcf_prep`
         - input: above output cleaned VCF
         - output: `somatic_anno/prep/{SAMPLE}-somatic.vcf.gz`
         - annotate `TUMOR/NORMAL_`-`AF/DP/VD` fields for PCGR
           - <https://github.com/umccr/vcf_stuff/blob/master/scripts/pcgr_prep>
       - `sage_pon`
         - input: above output VCF, `hmf_pon` VCF with
           `PON_COUNT`/`PON_MAX`/`PON_TOTAL` columns for annotation
         - output: `somatic_anno/sage_pon/{SAMPLE}-somatic.vcf.gz`
         - annotates VCF with `SageGermlinePon.hg38.98x.vcf.gz` HMF PoN counts
       - `somatic_vcf_pon_anno`
         - input: above output VCF, and `panel_of_normals_dir` (with
           `pon.snps.vcf.gz` and `pon.indels.vcf.gz`)
         - output: `somatic_anno/pon/{SAMPLE}-somatic.vcf.gz`
         - annotates with `INFO/PoN_CNT`, optionally
           `INFO/PoN_CNT>=filter_hits with FILTER=PoN`
           - <https://github.com/umccr/vcf_stuff/blob/master/scripts/pon_anno>
       - `somatic_vcf_pcgr_round1`
         - input: above output VCF, and PCGR reference data (`pcgr_data`)
         - output:
           - `somatic_anno/pcgr_run/{SAMPLE}-somatic.pcgr_ready.vep.vcf.gz`
           - `somatic_anno/pcgr_run/{SAMPLE}-somatic.pcgr.snvs_indels.tiers.tsv`
         - Runs PCGR (first time) via
           <https://github.com/umccr/clindet/blob/master/scripts/pcgr_wrap>
       - `somatic_vcf_pcgr_anno`
         - input:
           - above output VCF + tiers files
           - annotated VCF from `somatic_vcf_pon_anno` step
         - output: `somatic_anno/pcgr_ann/{SAMPLE}-somatic.vcf.gz`
         - annotate with `PCGR_` -
           `SYMBOL`,`TIER`,`CONSEQUENCE`,`MUTATION_HOTSPOT`,`PUTATIVE_DRIVER_MUTATION`,`TCGA_PANCANCER_COUNT`,`CLINVAR_CLNSIG`,
           and `COSMIC_CNT`, `ICGC_PCAWG_HITS`, `CSQ`
       - `annotate`
         - input: above output VCF
         - output: `work/{batch}/small_variants/annotate/{batch}-somatic.vcf.gz`
         - simply copies input to output

6. `somatic_vcf_filter`

   - Runs `filter_somatic_vcf` from `vcf_stuff`
     - <https://github.com/umccr/vcf_stuff/blob/master/scripts/filter_somatic_vcf>
   - input: above final output VCF
     (`work/{batch}/small_variants/annotate/{batch}-somatic.vcf.gz`)
   - output: `{batch}/small_variants/{batch}-somatic.vcf.gz`
   - steps:
     - Keep where `INFO/PCGR_TIER in [1, 2]`
     - Keep where `INFO/SAGE_HOTSPOT == 'known'`
     - Keep where `INFO/TIER == 'HOTSPOT'`
     - Dump where `INFO/TUMOR_VD < 4` (too few reads support variant)
     - Dump where `INFO/PoN_CNT >= 5` (in PoN, likely germline or artefact)
       - Report as Germline if is otherwise PASSed and `INFO/TUMOR_AF >= 0.2`
         - See the `germline_leakage` rule in `germline.smk`
     - Keep potential hotspots:
       - `HMF_HOTSPOT`
       - `PCGR_INTOGEN_DRIVER_MUT`
       - `PCGR_MUTATION_HOTSPOT`
       - `PCGR_CLINVAR_CLNSIG` is 'pathogenic' or 'uncertain'
       - `COSMIC_CNT >= 10`
       - `PCGR_TCGA_PANCANCER_COUNT >= 5`
       - `ICGC_PCAWG_HITS >= 5`
     - Dump where `INFO/TUMOR_AF < 0.1`
     - Dump where has `INFO/ENCODE` flag (hits ENCODE blocklist)
     - Dump indels in homopolymers (`INFO/MSILEN` and `INFO/MSI` plus formula)
     - Dump where `INFO/TUMOR_VD < 6` and:
       - variant in low complexity region (LCR)
       - no `INFO/HMF_GIAB_CONF` flag
       - `INFO/HMF_MAPPABILITY < 0.9`
     - Dump indels in bad promoters
     - Dump strand biased variants based on Vardict
     - (DRAGEN) Dump where `INFO/TLOD < 15`
     - Dump where `INFO/gnomAD_AF >= 0.01`
       - Report as Germline if is otherwise PASSed
         - See the `germline_leakage` rule in `germline.smk`

7. `somatic_vcf_filter_pass`

   - Keep only PASS from above filtered VCF
   - input: above output VCF
   - output: `{batch}/small_variants/{batch}-somatic-PASS.vcf.gz`

   - The `{batch}/small_variants/{batch}-somatic-PASS.vcf.gz` VCF is also passed
     as input to:
     - `Pierian`
     - `vcf2maf.pl`
     - `bcftools stats`
     - `PCGR`

### `pcgr.smk`

1. `run_pcgr`

   - run PCGR with purity and ploidy as inferred by PURPLE
     - uses the `scripts/pcgr` wrapper
     - raw PCGR outputs get renamed to remove the `_acmg.hg38` suffix
   - input:
     - `{batch}/small_variants/{batch}-somatic-PASS.vcf.gz`
     - PCGR reference data (`pcgr_data`)
     - `work/{batch}/purple/{batch}.purple.purity.tsv`
   - output:
     - HTML: `work/{batch}/pcgr/{batch}-somatic.pcgr.html`
     - VCF: `work/{batch}/pcgr/{batch}-somatic.pcgr.pass.vcf.gz`
     - TSV: `work/{batch}/pcgr/{batch}-somatic.pcgr.snvs_indels.tiers.tsv`

2. `pcgr_copy_report`

   - copy HTML and TSV (not VCF) into final `clindetd/{batch}/` directory
   - input: above HTML and TSV outputs
   - output:
     - `{batch}/{batch}-somatic.pcgr.html`
     - `{batch}/small_variants/{batch}-somatic.pcgr.snvs_indels.tiers.tsv`

3. PCGR notes

- Step 0: Validate input data and options
  - Runs `scripts/pcgr_validate_input.py`
  - input: raw VCF input to PCGR
  - output: `pcgr_ready.vcf.gz` decomposed with no FORMAT or sample columns
- Step 1: VEP annotation
  - Runs `vep` with lots of options
  - input: `pcgr_ready.vcf.gz`
  - output: `pcgr_ready.vep.vcf.gz`
- Step 2: vcfanno precision oncology
  - Runs `pcgr_vcfanno.py`
  - input: `pcgr_ready.vep.vcf.gz`
  - output: `pcgr_ready.vep.vcfanno.vcf.gz`
- Step 3: Cancer gene annotations with pcgr-summarise
  - `pcgr_summarise.py`
  - `vcf2tsv.py`
- Step 4: Generation of outputs/reports
  - Uses `pcgrr` functions via the `pcgrr.R` CLI

### `structural.smk`

1. `sv_keep_pass`

   - Reset INFO (`SIMPLE_ANN`, `SV_HIGHEST_TIER`) and FILTER (`Intergenic`,
     `MissingAnn`, `REJECT`) fields. Keep only **PASS** variants.
   - input: final Manta VCF from DRAGEN tumor/normal workflow
   - output: `work/{batch}/structural/keep_pass/{batch}-manta.vcf.gz`

2. `sv_snpeff_maybe`

   - Run snpEff **if** there is **not** an `INFO/ANN` annotation.
     - use `-hgvs`, `-cancer`, `-csvStats`, `-s`, `-dataDir` options
     - **else**, just copy input to output
   - input:
     - above output VCF
     - snpEff database
   - output: `work/{batch}/structural/snpeff/{batch}-sv-snpeff.vcf.gz`

3. `sv_vep`

   - Run VEP on final Manta VCF
   - input:
     - final Manta VCF from DRAGEN tumor/normal workflow
     - PCGR data directory (for the VEP reference data)
       - FASTA file:
         `grch38/.vep/homo_sapiens/105_GRCh38/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz`
   - output: `work/{batch}/structural/vep/{batch}-sv-vep.vcf.gz`

4. `fix_snpeff`

   - Replace the wrongly capitalised ALT fields with lowercase to avoid
     downstream bugs
     - TODO: turn the multiple `sed` commands into a single one with `-e`.
   - input: snpEff output VCF
   - output: `work/{batch}/structural/snpeff/{batch}-sv-snpeff-fix.vcf.gz`

5. `sv_prioritize`

   - Run <https://github.com/umccr/vcf_stuff/blob/master/scripts/prioritize_sv>
   - input: above fixed snpEff VCF
   - output: `work/{batch}/structural/prioritize/{batch}-sv-eff-prio.vcf.gz`

6. `sv_subsample_if_too_many`

   - If >= 50,000 SVs, progressively remove TIER 4/3/2 SVs (in that order).
     - **TODO**: compress output VCF
   - input: above sv prioritised VCF
   - output:
     `work/{batch}/structural/sv_subsample_if_too_many/{batch}-manta.vcf`

7. `sv_bpi_maybe`

   - Run BPI on above output VCF
   - input: above output VCF, T/N BAMs
   - output: `work/{batch}/structural/maybe_bpi/{batch}-manta.vcf`

8. `filter_sv_vcf`

   - Filters in sequence:
     - keep PASS FILTER
     - dump TIER 3/4 where `SR < 5 & PR < 5`
     - dump TIER 3/4 where `SR < 10 & PR < 10 & (AF0 < 0.1 | AF1 < 0.1)`
     - **TODO**: reorg this
   - input: above BPI output VCF
   - output: `work/{batch}/structural/filt/{batch}-manta.vcf.gz`
     - This is fed to PURPLE.

9. `reprioritize_rescued_svs`

   - Run <https://github.com/umccr/vcf_stuff/blob/master/scripts/prioritize_sv>
     after PURPLE. Also remove `INFO/ANN` annotation.
   - input:
     - purple SVs: `work/{batch}/purple/{batch}.purple.sv.vcf.gz`
   - output: `work/{batch}/structural/sv_after_purple/{batch}-manta.vcf.gz`

10. `copy_sv_vcf_ffpe_mode`

    - Copy either the filtered or the purple prioritised to the final output
    - input: filtered or purple prioritised VCF
    - output: `{batch}/structural/{batch}-manta.vcf.gz`

11. `prep_sv_tsv`

    - input: above final VCF
    - output: `{batch}/structural/{batch}-manta.tsv`
    - Parse info from the VCF and export to TSV
      - give non-tiered variants an `INFO/SV_TOP_TIER` of `4`.
      - set `simple_ann = INFO/SIMPLE_ANN`, and `PURPLE_status = ''`
        - for purple inferred variants:
          - `simple_ann = {INFO/SVTYPE}||||From_CNV|{tier}`
          - `PURPLE_status = 'INFERRED'`
        - for purple recovered variants:
          - `PURPLE_status = 'RECOVERED'`
      - there are 23 columns:
        - `caller = 'manta'`, `sample = tumor name`, `chrom = CHROM`,
          `start = POS`, `end = INFO/END`
        - `svtype = INFO/SVTYPE`
        - `split_read_support, paired_support_PE/PR = FORMAT/SR-PE-PR for tumor`
        - `AF_BPI = INFO/BPI_AF`, `somaticscore = INFO/SOMATICSCORE`
        - `tier = INFO/SV_TOP_TIER` (or `4` if missing)
        - `annotation = INFO/SIMPLE_ANN`
        - `PURPLE_`: `AF`, `CN`, `CN_CHANGE`, `PLOIDY`, `STATUS` (`INFERRED` or
          `RECOVERED`)
        - `START/END_BPI = BPI_START/END`
        - `ID = ID`
        - `MATEID = INFO/MATEID`
        - `ALT = ALT[0]`

### `oncoviruses.smk`

1. `viral_content`
   - input:
     - tumor BAM
     - refdata

- output1: `prioritized_oncoviruses.tsv`

```
## Viral sequences (from https://gdc.cancer.gov/about-data/data-harmonization-and-generation/gdc-reference-files) found in unmapped reads
## Sample: MDX230148
## Minimal completeness: 50.0% at 1x or 1000bp at 5x
#virus  size    depth   1x      5x      25x     significance
HPV45   7858    67.1    0.768   0.767   0.767   significant
HCV-2   9711    33.0    0.012   0.011   0.010   .
HPV71   8037    20.8    0.011   0.011   0.009   .
HCV-1   9646    6.3     0.011   0.010   0.010   .
HPV19   7685    1.9     0.010   0.009   0.009   .
[...]
```

- output2: `present_viruses.txt`
  - grab the `significant` viruses from above

```
HPV45
```

- command:

```
oviraptor \
  {tumor_bam} \
  -o {work_dir} \
  -s {tumor_name} \
  --genomes-dir {refdata} \
  --only-detect # just detect without finding integration sites, do that in next step
```

2. `viral_integration_sites`
   - input:
     - tumor BAM
     - `present_viruses.txt` output from above

- output1:
  - `{batch}/oncoviruses/oncoviral_breakpoints.vcf`

```
chr7    19105901        3_1     N       N[HPV45:3062[   .       PASS    SVTYPE=BND;STRANDS=+-:44;EVENT=3;MATEID=3_2;CIPOS=-3,2;CIEND=-10,9;CIPOS95=0,0;CIEND95=0,0;SU=44;PE=34;SR=10;DisruptedGenes=TWIST1;GenesWithin100kb=AC003986.2,AC003986.3,TWIST1,AC003986.1  GT:SU:PE:SR     ./.:44:34:10
chr7    19105936        4_1     N       ]HPV45:1236]N   .       PASS    SVTYPE=BND;STRANDS=-+:91;EVENT=4;MATEID=4_2;CIPOS=0,0;CIEND=-10,3;CIPOS95=0,1;CIEND95=0,0;IMPRECISE;SU=91;PE=64;SR=27;DisruptedGenes=TWIST1;GenesWithin100kb=AC003986.2,AC003986.3,TWIST1,AC003986.1 GT:SU:PE:SR     ./.:91:64:27
chr13   98758355        5_1     N       N]HPV45:5033]   .       PASS    SVTYPE=BND;STRANDS=++:5;EVENT=5;MATEID=5_2;CIPOS=-10,9;CIEND=-10,9;CIPOS95=0,0;CIEND95=0,0;SU=5;PE=0;SR=5;GenesWithin100kb=SLC15A1,DOCK9-AS1    GT:SU:PE:SR     ./.:5:0:5
HPV45   1237    4_2     N       N[chr7:19105935[        .       PASS    SVTYPE=BND;STRANDS=+-:91;SECONDARY;EVENT=4;MATEID=4_1;CIPOS=-10,3;CIEND=0,0;CIPOS95=0,0;CIEND95=0,1;IMPRECISE;SU=91;PE=64;SR=27;DisruptedGenes=TWIST1;GenesWithin100kb=AC003986.2,AC003986.3,TWIST1,AC003986.1       GT:SU:PE:SR     ./.:91:64:27
HPV45   3063    3_2     N       ]chr7:19105900]N        .       PASS    SVTYPE=BND;STRANDS=-+:44;SECONDARY;EVENT=3;MATEID=3_1;CIPOS=-10,9;CIEND=-3,2;CIPOS95=0,0;CIEND95=0,0;SU=44;PE=34;SR=10;DisruptedGenes=TWIST1;GenesWithin100kb=AC003986.2,AC003986.3,TWIST1,AC003986.1        GT:SU:PE:SR     ./.:44:34:10
HPV45   5034    5_2     N       N]chr13:98758354]       .       PASS    SVTYPE=BND;STRANDS=++:5;SECONDARY;EVENT=5;MATEID=5_1;CIPOS=-10,9;CIEND=-10,9;CIPOS95=0,0;CIEND95=0,0;SU=5;PE=0;SR=5;GenesWithin100kb=SLC15A1,DOCK9-AS1  GT:SU:PE:SR     ./.:5:0:5
```

- command:

```

oviraptor \
  {tumor_bam} \
  -o {work_dir} \
  -s {tumor_name} \
  --genomes-dir {genomes_dir} \
  -v $(cat present_viruses.txt)
```

3. `oncoviruses_breakpoints_tsv`
   - input:
     - `{batch}/oncoviruses/oncoviral_breakpoints.vcf` output from above
     - `work/{batch}/oncoviruses/present_viruses.txt` output from above-above

- command:
  - Parse VCF from above, grab FORMAT PE/SR fields and add to `PAIR_COUNT`
- output1:
  - `work/{batch}/oncoviruses/oncoviral_breakpoints.tsv`

```
# A tibble: 6 × 10
  sample    contig    start end   svtype PAIR_COUNT DisruptedGenes UpstreamGenes                      ID    MATEID
  <chr>     <chr>     <dbl> <lgl> <chr>       <dbl> <chr>          <chr>                              <chr> <chr>
1 MDX230148 chr7   19105901 NA    BND            44 TWIST1         AC003986.2, AC003986.3, AC003986.1 3_1   3_2
2 MDX230148 chr7   19105936 NA    BND            91 TWIST1         AC003986.2, AC003986.3, AC003986.1 4_1   4_2
3 MDX230148 chr13  98758355 NA    BND             5 NA             SLC15A1, DOCK9-AS1                 5_1   5_2
4 MDX230148 HPV45      1237 NA    BND            91 NA             .                                  4_2   4_1
5 MDX230148 HPV45      3063 NA    BND            44 NA             .                                  3_2   3_1
6 MDX230148 HPV45      5034 NA    BND             5 NA             .                                  5_2   5_1
```

#### oviraptor - https://github.com/umccr/oviraptor

1. `extract_unmapped_and_mate_unmapped_reads`

   - input: tumor BAM
   - output: `step1_host_unmapped_or_mate_unmapped.namesorted.bam`
   - command:
     - `sambamba view -F 'unmapped or mate_is_unmapped' ... | samtools sort -n ...`

2. `unmapped_and_mate_unmapped_reads_to_fastq`

   - input: output BAM from above rule
   - output:
     - `step2_host_unmapped_or_mate_unmapped.R1.fq`
     - `step2_host_unmapped_or_mate_unmapped.R2.fq`
     - `step2_host_unmapped_or_mate_unmapped.single.fq`
   - command: `samtools fastq input_bam ...`

3. `bwa_unmapped_and_mate_unmapped_reads_to_gdc`
   - input:
     - paired FASTQs from above
     - gds viral FASTA (this is where EBV gets lost; see
       https://github.com/umccr/clindet/issues/143)
   - output:
     - `detect_viral_reference/host_unmapped_or_mate_unmapped_to_gdc.bam`
   - command:

```
minimap2 \
  -ax sr \
  -Y \
  -t{threads} \
  -R '{params.rg}' \
  {input.gdc_fa} {input.fq1} {input.fq2} \
    | samtools sort -@{threads} -Obam -o {output.gdc_bam}
```

4. `index_virus_bam`

   - Just `samtools index` above output BAM

5. `mosdepth`
   - Runs mosdepth using the GDS viral FASTA index

- output1: `thresholds.bed.gz`

```
#chrom	start	end	region	1X	5X	25X
CMV	0	235646	unknown	27	0	0
HBV	0	3215	unknown	0	0	0
HCV-1	0	9646	unknown	104	98	94
HCV-2	0	9711	unknown	116	104	98
HIV-1	0	9181	unknown	0	0	0
HIV-2	0	10359	unknown	0	0	0
KSHV	0	137969	unknown	28	27	0
HTLV-1	0	8507	unknown	0	0	0
MCV	0	5387	unknown	0	0	0
[...]
```

- output2: `regions.bed.gz`

```
CMV	0	235646	0.00
HBV	0	3215	0.00
HCV-1	0	9646	6.28
HCV-2	0	9711	33.05
HIV-1	0	9181	0.00
HIV-2	0	10359	0.00
KSHV	0	137969	0.00
HTLV-1	0	8507	0.00
MCV	0	5387	0.00
SV40	0	5243	0.00
[...]
```

6. `prioritize_viruses`

- input: above mosdepth output files
- output: `prioritized_oncoviruses.tsv`
