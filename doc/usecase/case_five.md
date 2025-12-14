# Use case V: Switching to different genome version (e.g. hg38)

In a recent article titled "Choose your human genome reference wisely," published in (**Nature Methods**)[https://www.nature.com/articles/s41592-025-02850-9], the authors provide a systematic overview of the different versions of the human reference genome used in bioinformatics and offer guidance on selecting the appropriate genome assembly.
Over the past few decades, multiple versions of the human genome have been developed, such as hg38, hg38, T2T-CHM13, and various pan-genome assemblies. These versions differ significantly in aspects like gene annotation accuracy and chromosomal assembly completeness. Therefore, selecting a suitable genomic reference is a critical step in data analysis.

```{image} ./choose_genome.png
:alt: glioma
:class: bg-primary
:width: 600px
:align: center
```

In this report, the researchers note that the overwhelming majority of clinical testing laboratories still rely on GRCh37. The primary obstacle to updating is a shortage of technical personnel with the requisite expertise, making the perceived cost of migration outweigh the benefits. ClinDet effectively addresses this challenge. Therefore, in this case study, we demonstrate how to use ClinDet to seamlessly switch the analytical genome reference to hg38.

```{image} ./hg38_transfer.png
:alt: glioma
:class: bg-primary
:width: 600px
:align: center
```

**Let's begin this section**:

## Download required files
The required files listed below can be downloaded manually. Alternatively, to simplify this tedious configuration, ClinDet offers the [build_hg38.sh](./build_hg38.sh) script for automated downloading, which is customizable to meet user requirements.

1. genome fasta, dict, annotation GTF 
2. DBSNP, ASCAT loci, allele files. 
3. config files for hmftools, GATK tools. 
4. config files for Sanger tools (CaVEMan, BRASS, cgppindel).





## modify YAML file
if you are not familiarity with yaml format, see [en](https://yaml.org/), [zh](https://www.runoob.com/w3cnote/yaml-intro.html).

### modify config.yaml for mutation detection 
add hg38 config files to `config['resource']` section
```yaml
  hg38:
    REFFA: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta"
    GENOME_BED: ""
    GTF: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/gencode.v49.annotation.gtf"
    WES_PON: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/1000g_pon.hg38.vcf.gz"
    WES_BED: 
    WGS_PON: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/1000g_pon.hg38.vcf.gz"
    DBSNP: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Homo_sapiens_assembly38.dbsnp138.vcf"
    DBSNP_GZ: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Homo_sapiens_assembly38.dbsnp138.vcf.gz"
    DBSNP_INDEL: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/1000G_phase1.indels.hg38.vcf.gz"
    MUTECT2_VCF: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/af-only-gnomad.hg38.vcf.gz"
    REFFA_DICT: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta"
    MUTECT2_germline_vcf: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/af-only-gnomad.hg38.vcf.gz"
    common_vcf: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/00-common_all.vcf.gz"
    RNA_EDIT_VCF: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hg38.RNAediting.vcf.gz"
```


add hg38 config files to `config['resource']['varanno']` section
```yaml
hg38:
    KNOWN_SITES1: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz"
    KNOWN_SITES2: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/1000G_phase1.indels.hg38.vcf.gz"
```

add hg38 config `config['singularity']['cgppindel']` section
```yaml
hg38:
    species: "HUMAN"
    genes: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/refarea_pindel/codingexon_regions.indel.bed.gz"
    softfil: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/pindel/WXS_Rules.lst"
    simrep: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/pindel/simpleRepeats.bed.gz"
    normal_panel: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/pindel/pindel_np.gff3.gz"
    WES:
    filter: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/pindel/WXS_Rules.lst"
    normal_panel: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/pindel/pindel_np.gff3.gz"
    WGS:
    filter: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/pindel/WGS_Rules.lst"
    normal_panel: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/pindel/pindel_np.gff3.gz"
```

add hg38 config `config['singularity']['caveman']` section
```yaml
hg38:
    ignorebed: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/cgpCaVEManWrapper_CPBI_refarea/hi_seq_depth.bed"
    flag:
    c: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/caveman/flagging/flag.vcf.config.ini"
    v: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/caveman/flagging/flag.to.vcf.convert.ini"
    u: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/caveman/flagging"
    g: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/caveman/unmatchedNormal.bed.gz"
    b: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/caveman/flagging"
    ab: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/SNV_INDEL_ref/caveman/flagging"
    s: "HUMAN"
```

add hg38 config `config['softwares']['vcf2maf']['build_version']`  and `config['softwares']['vcf2maf']['vep']` section
```yaml
    build_version:
      hg38: "GRCh38"
    vep:
      hg38:
        vep_data: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/vep"
        vep_path: ""
        cache_version: "110"
        species: "homo_sapiens"
```


## modify config.yaml for CNV  detection
add hg38 config `config['softwares']['sequenza']` section
```yaml
hg38:
    gc: "" 
```


add hg38 config `config['softwares']['ascat']` section
```yaml
hg38:
    loci_1000: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/ASCAT/WES/G1000_lociAll_hg38/G1000_loci_hg38_chr"
    alleles_1000: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/ASCAT/WES/G1000_allelesAll_hg38/G1000_alleles_hg38_chr"
    replictimingfile: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/ASCAT/WES/RT_G1000_hg38.txt"
    GCcontentfile: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/ASCAT/WES/GC_G1000_hg38.txt"
```

add hg38 config `config['singularity']['freec']` section
```yaml
hg38:
    chrFiles: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/fasta"
    chrLenFile: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta.auto.fai"
    snp_file: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hapmap_3.3.hg38.vcf.gz"
    sambamba: '/AbsoPath/of/conda/envs/freec/bin/sambamba'
    bedtools: '/AbsoPath/of/conda/envs/freec/bin/bedtools'
```

## modify config.yaml for SV detection

add hg38 config `config['singularity']['brass']` section
```yaml
hg38:
    gc: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/VAGrENT_ref_GRCh38_hla_decoy_ebv_ensembl_91/vagrent/vagrent.cache.gz"
    b: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/CNV_SV_ref_GRCh38_hla_decoy_ebv_brass6+/brass/500bp_windows.gc.bed.gz"
    d: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/CNV_SV_ref_GRCh38_hla_decoy_ebv_brass6+/brass/HiDepth.bed.gz"
    cb: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/CNV_SV_ref_GRCh38_hla_decoy_ebv_brass6+/brass/cytoband.txt"
    ct: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/CNV_SV_ref_GRCh38_hla_decoy_ebv_brass6+/brass/CentTelo.tsv"
    vi: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/Sanger/CNV_SV_ref_GRCh38_hla_decoy_ebv_brass6+/brass/viral.genomic.fa.2bit"
    mi: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/CNV_SV_ref_GRCh38_hla_decoy_ebv_brass6+/brass/all_ncbi_bacteria"
```

## modify config.yaml for RNA expression 
add hg38 config `config['softwares']['star']['index']`
```yaml
    hg38: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/STAR/hg38"
```
and `config['softwares']['salmon']['index']` section
```yaml
    hg38: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/salmon/hg38"
```

and `config['softwares']['kallisto']['index']` section
```yaml
    hg38: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/salmon/hg38"
```

and `config['softwares']['rsem']['index']` section
```yaml
    hg38: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/RSEM/hg38"
```


## modify config.yaml for all HMFtools 
add hg38 config['singularity']['hmftools']
```yaml
hg38:
    # AMBER
    heterozygous_sites: '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/AmberGermlineSites.38.tsv.gz'
    # COBALT
    gc_profile:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/GC_profile.1000bp.38.cnp'
    diploid_bed:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/DiploidRegions.38.bed.gz'
    # CUPPA
    cuppa_alt_sj:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/cuppa/alt_sj.selected_loci.38.tsv.gz'
    cuppa_classifier:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/cuppa/cuppa_classifier.38.pickle.gz'
    # SV Prep
    sv_prep_blocklist:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/sv_prep_blacklist.38.bed'
    # ESVEE
    decoy_sequences_image:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/hg38_decoys.fa.img'
    gridss_pon_breakends:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/sgl_pon.38.bed.gz'
    gridss_pon_breakpoints:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/sv_pon.38.bedpe.gz'
    repeatmasker_annotations:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/repeat_mask_data.38.fa.gz'
    # Isofox
    alt_sj_distribution:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/rna/isofox.hmf_38_151_2600.alt_sj_cohort.csv.gz'
    gene_exp_distribution:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/rna/isofox.hmf_38_151_2600.gene_distribution.csv.gz'
    isofox_counts:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/rna/read_151_exp_counts.38.csv'
    isofox_gc_ratios:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/rna/read_100_exp_gc_ratios.38.csv'
    # LILAC
    lilac_resources:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/lilac/'
    # Neo
    neo_resources:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/neo/binding/'
    cohort_tpm_medians: '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/neo/tpm_cohort/isofox.hmf_38_151_2600.transcript_medians.csv.gz'
    # CIDER
    cider_blastdb:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/cider/blastdb/'
    # PEACH
    peach_haplotypes:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/peach/haplotypes.38.tsv'
    peach_haplotype_functions:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/peach/haplotype_functions.38.tsv'
    peach_drug_info:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/peach/peach_drugs.38.tsv'
    # ORANGE
    cohort_mapping:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/orange/cohort_mapping.tsv'
    cohort_percentiles: '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/orange/cohort_percentiles.tsv'
    disease_ontology:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/orange/doid.json'
    # SAGE
    clinvar_annotations:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/clinvar.38.vcf.gz'
    sage_blocklist_regions:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/KnownBlacklist.germline.38.bed'
    sage_blocklist_sites:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/KnownBlacklist.germline.38.vcf.gz'
    sage_actionable_panel:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/ActionableCodingPanel.38.bed.gz'
    sage_coverage_panel:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/CoverageCodingPanel.38.bed.gz'
    sage_highconf_regions:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-X_v.3.3.2_highconf_nosomaticdel_noCENorHET7.bed.gz'
    sage_known_hotspots_germline:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/KnownHotspots.germline.38.vcf.gz'
    sage_known_hotspots_somatic:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/KnownHotspots.somatic.38.vcf.gz'
    sage_pon:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/hmf_wgs_sage_pon_1000.38.tsv.gz'
    # Sigs
    sigs_signatures:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/sigs/snv_cosmic_signatures.csv'
    sigs_etiology:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/sigs/signatures_etiology.tsv'
    # Virus breakend
    virusbreakend_db:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/virusbreakend/'
    # Virus Interpreter
    virus_reporting_db: '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/virusinterpreter/virus_reporting_db.tsv'
    virus_taxonomy_db:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/virusinterpreter/taxonomy_db.tsv'
    virus_blocklist_db: '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/misc/virusinterpreter/virus_blacklisting_db.tsv'
    # Misc
    driver_gene_panel:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/common/DriverGenePanel.38.tsv'
    ensembl_data_resources:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/common/ensembl_data/'
    unmap_regions:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/common/unmap_regions.38.tsv'
    gnomad_resource:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/gnomad_variants_v38.csv.gz'
    gridss_config:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/gridss.properties'
    known_fusion_data:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/known_fusion_data.38.csv'
    known_fusions:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/known_fusions.38.bedpe'
    msi_jitter_sites:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/msi_jitter_sites.38.tsv.gz'
    purple_germline_del:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/cohort_germline_del_freq.38.csv'
    segment_mappability:  '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/mappability_150.38.bed.gz'
    # tool spec config
    amber:
    loci: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38//hmf_pipeline_resources/GermlineHetPon.38.vcf.gz"
    snp_check_vcf: '/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/Amber.snpcheck.38.vcf'
    cobalt:
    ref_genome_version: 38
    tumor_only_diploid_bed: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/DiploidRegions.38.bed.gz"
    gc_profile: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/GC_profile.1000bp.38.cnp"
    purple:
    ref_genome_version: 38
    tumor_only_diploid_bed: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/DiploidRegions.38.bed.gz"
    gc_profile: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/GC_profile.1000bp.38.cnp"
    ensembl_data_dir: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/common/ensembl_data"
    somatic_hotspots: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/KnownHotspots.somatic.38.vcf.gz"
    driver_gene_panel: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/common/DriverGenePanel.38.tsv"
    linx:
    ref_genome_version: 38
    tumor_only_diploid_bed: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/DiploidRegions.38.bed.gz"
    gc_profile: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/copy_number/GC_profile.1000bp.38.cnp"
    ensembl_data_dir: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/common/ensembl_data"
    somatic_hotspots: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/KnownHotspots.somatic.38.vcf.gz"
    driver_gene_panel: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/common/DriverGenePanel.38.tsv"
    known_fusion_file: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/known_fusion_data.38.csv"
    sage:
    ref_genome_version: 38
    ensembl_data_dir: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/common/ensembl_data"
    coverage_bed: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/CoverageCodingPanel.38.bed.gz"
    hotspots: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/KnownHotspots.somatic.38.vcf.gz "
    panel_bed: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/ActionableCodingPanel.38.bed.gz"
    high_confidence_bed: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/variants/NA12878_GIAB_highconf_IllFB-IllGATKHC-CG-Ion-Solid_ALLCHROM_v3.2.2_highconf.bed.gz"
    esvee:
    ref_genome_version: 38
    ensembl_data_dir: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/common/ensembl_data"
    known_fusion_bed: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/known_fusions.38.bedpe"
    blacklist: "/AbsoPath/of/clindet/folder/resources/ref_genome/hg38/hmf_pipeline_resources/dna/sv/gridss_blacklist.38.bed.gz"
```


## re-run WES data in use case I


