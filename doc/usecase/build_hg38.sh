set -euo pipefail
RED='\e[31m'
RED_B='\e[41m'
NC='\e[0m'
GREEN='\e[32m'
GREEN_B='\e[42m'
bold='\e[1;43m'
mkdir -p build_log/hg38

### parallel conda install
cleanup() {
        pkill -P $$
        kill 0
}

for sig in INT QUIT HUP TERM; do
        trap "
            cleanup
            trap - $sig EXIT
            kill -s $sig "'"$$"' "$sig"
done
declare -a pids;


conda activate gsutil
mkdir -p resources/ref_genome/hg38

# check gsutil
command='gsutil'
if type $command >/dev/null 2>&1; then
    echo -e "${GREEN_B}Check  OK ${NC}, ${bold} ${command} ${NC} existed, Start download and config."
else
    echo -e "${RED_B}ERROE:  ${NC} ${bold} ${command} ${NC} Not exited !!!!"
    exit 1 
fi


## Download hg38 genome
echo "Beginning hg38 genome fasta Download ..."
if [ ! -f "build_log/hg38/download_hg38.log" ]; then
    echo "Start download from hmf ..."
    gsutil -m cp -r -n \
      "gs://hmf-public/HMFtools-Resources/ref_genome/38/GRCh38_masked_exclusions_alts_hlas.fasta" \
      "gs://hmf-public/HMFtools-Resources/ref_genome/38/GRCh38_masked_exclusions_alts_hlas.fasta.dict" \
      "gs://hmf-public/HMFtools-Resources/ref_genome/38/GRCh38_masked_exclusions_alts_hlas.fasta.fai" \
      resources/ref_genome/hg38
    echo "Done"
    touch build_log/hg38/download_hg38.log
else
    echo -e "${GREEN_B} already download hg38 reference, continue ${NC}"
fi


## Download hg38 hmftools softwares data

echo "Beginning hg38 hmftools data Download ..."
if [ ! -f "build_log/hg38/download_hg38_hmftools.log" ]; then
    echo "Start download from hmf ..."
    gsutil -m cp -r -n \
      "gs://hmf-public/HMFtools-Resources/pipeline/oncoanalyser/2.2/38/hmf_panel_resources.tso500.38_v2.2.0--3.tar.gz" \
      "gs://hmf-public/HMFtools-Resources/pipeline/oncoanalyser/2.2/38/hmf_pipeline_resources.38_v2.2.0--3.tar.gz" \
      resources/ref_genome/hg38
    echo -e "${GREEN_B} Download Done ${NC}"

    wget -P resources/ref_genome/hg38/hmf_pipeline_resources -c https://www.bcgsc.ca/downloads/morinlab/hmftools-references/amber/GermlineHetPon.hg38.vcf.gz
    wget -P resources/ref_genome/hg38/hmf_pipeline_resources -c https://www.bcgsc.ca/downloads/morinlab/hmftools-references/amber/GermlineHetPon.hg38.snpcheck.vcf.gz
    wget -P resources/ref_genome/hg38/hmf_pipeline_resources -c https://www.bcgsc.ca/downloads/morinlab/hmftools-references/amber/Amber.snpcheck.38.vcf
    
    mkdir -p resources/ref_genome/hg38/hmf_pipeline_resources
    tar -xzvf resources/ref_genome/hg38/hmf_panel_resources.tso500.38_v2.2.0--3.tar.gz --strip-components 1 -C resources/ref_genome/hg38/hmf_pipeline_resources/
    tar -xzvf resources/ref_genome/hg38/hmf_pipeline_resources.38_v2.2.0--3.tar.gz --strip-components 1 -C resources/ref_genome/hg38/hmf_pipeline_resources/

    echo -e "${GREEN_B} Decompression Done ${NC}"
    touch build_log/hg38/download_hg38_hmftools.log
else
    echo -e "${GREEN_B} already download hmftools hg38 resources, continue ${NC}"
fi



## Download hg38 GATK tools data
echo "Beginning hg38 GATK files Download ..."
if [ ! -f "build_log/hg38/download_hg38_gatk.log" ]; then
    gsutil -m cp -r -n \
        "gs://genomics-public-data/resources/broad/hg38/v0/1000G_omni2.5.hg38.vcf.gz" \
        "gs://genomics-public-data/resources/broad/hg38/v0/1000G_omni2.5.hg38.vcf.gz.tbi" \
        "gs://genomics-public-data/resources/broad/hg38/v0/1000G_phase1.snps.high_confidence.hg38.vcf.gz" \
        "gs://genomics-public-data/resources/broad/hg38/v0/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi" \
        "gs://genomics-public-data/resources/broad/hg38/v0/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz" \
        "gs://genomics-public-data/resources/broad/hg38/v0/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz.tbi" \
        "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf" \
        "gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.idx" \
        resources/ref_genome/hg38

    gsutil -m cp -n -r \
        "gs://gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz" \
        "gs://gatk-best-practices/somatic-hg38/1000g_pon.hg38.vcf.gz.tbi" \
        "gs://gatk-best-practices/somatic-hg38/af-only-gnomad.hg38.vcf.gz" \
        "gs://gatk-best-practices/somatic-hg38/af-only-gnomad.hg38.vcf.gz.tbi" \
        resources/ref_genome/hg38

    # download other file from Peking U FTP
    wget -P resources/ref_genome/hg38 -c http://ftp.cbi.pku.edu.cn/pub/mirror/GATK/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
    wget -P resources/ref_genome/hg38 -c http://ftp.cbi.pku.edu.cn/pub/mirror/GATK/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi
    wget -P resources/ref_genome/hg38 -c http://ftp.cbi.pku.edu.cn/pub/mirror/GATK/hg38/dbsnp_138.hg38.vcf.gz
    wget -P resources/ref_genome/hg38 -c http://ftp.cbi.pku.edu.cn/pub/mirror/GATK/hg38/dbsnp_138.hg38.vcf.gz.tbi
    wget -P resources/ref_genome/hg38 -c https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-common_all.vcf.gz
    wget -P resources/ref_genome/hg38 -c https://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/00-common_all.vcf.gz.tbi

    echo -e "${GREEN_B} download GATK tools hg38 resources Done ${NC}"
    touch build_log/hg38/download_hg38_gatk.log
else
    echo -e "${GREEN_B} already download GATK tools hg38 resources, continue ${NC}"
fi

## download ASCAT refdata
echo "Beginning ASCAT config files  Download ..."
if [ ! -f "build_log/hg38/download_ascat.log" ]; then
    mkdir -p resources/ref_genome/hg38/ASCAT/WES
    wget -P resources/ref_genome/hg38/ASCAT/WES -c https://zenodo.org/records/14008443/files/G1000_alleles_WES_hg38.zip
    wget -P resources/ref_genome/hg38/ASCAT/WES -c https://zenodo.org/records/14008443/files/G1000_loci_WES_hg38.zip
    wget -P resources/ref_genome/hg38/ASCAT/WES -c https://zenodo.org/records/14008443/files/GC_G1000_WES_hg38.zip
    wget -P resources/ref_genome/hg38/ASCAT/WES -c https://zenodo.org/records/14008443/files/RT_G1000_WES_hg38.zip

    unzip -d resources/ref_genome/hg38/ASCAT/WES resources/ref_genome/hg38/ASCAT/WES/G1000_alleles_WES_hg38.zip
    unzip -d resources/ref_genome/hg38/ASCAT/WES resources/ref_genome/hg38/ASCAT/WES/G1000_loci_WES_hg38.zip
    unzip -d resources/ref_genome/hg38/ASCAT/WES resources/ref_genome/hg38/ASCAT/WES/GC_G1000_WES_hg38.zip
    unzip -d resources/ref_genome/hg38/ASCAT/WES resources/ref_genome/hg38/ASCAT/WES/RT_G1000_WES_hg38.zip

    ## add chr prefix to loci
    for i in {1..22} X; do sed -i 's/^/chr/' resources/ref_genome/hg38/ASCAT/WES/G1000_lociAll_hg38/G1000_loci_hg38_chr${i}.txt; done

    wget -P resources/ref_genome/hg38/ASCAT/WGS -c https://zenodo.org/records/14008443/files/G1000_alleles_WGS_hg38.zip
    wget -P resources/ref_genome/hg38/ASCAT/WGS -c https://zenodo.org/records/14008443/files/G1000_loci_WGS_hg38.zip
    wget -P resources/ref_genome/hg38/ASCAT/WGS -c https://zenodo.org/records/14008443/files/GC_G1000_WGS_hg38.zip
    wget -P resources/ref_genome/hg38/ASCAT/WGS -c https://zenodo.org/records/14008443/files/RT_G1000_WGS_hg38.zip


    unzip -d resources/ref_genome/hg38/ASCAT/WGS resources/ref_genome/hg38/ASCAT/WGS/G1000_alleles_WGS_hg38.zip
    unzip -d resources/ref_genome/hg38/ASCAT/WGS resources/ref_genome/hg38/ASCAT/WGS/G1000_loci_WGS_hg38.zip
    unzip -d resources/ref_genome/hg38/ASCAT/WGS resources/ref_genome/hg38/ASCAT/WGS/GC_G1000_WGS_hg38.zip
    unzip -d resources/ref_genome/hg38/ASCAT/WGS resources/ref_genome/hg38/ASCAT/WGS/RT_G1000_WGS_hg38.zip

    ## add chr prefix to loci
    for i in {1..22} X; do sed -i 's/^/chr/' resources/ref_genome/hg38/ASCAT/WGS/G1000_loci_hg38_chr${i}.txt; done
    
    echo -e "${GREEN_B} ASCAT configs Downloaded ${NC}"
    touch build_log/hg38/download_ascat.log
else
    echo -e "${GREEN_B} already download GATK tools softwares, continue ${NC}"
fi
# Debugging settings
## Download CaVEMan,BRASS config data
echo "Beginning CaVEMan,BRASS config files  Download ..."
if [ ! -f "build_log/hg38/download_sanger.log" ]; then
    mkdir -p resources/ref_genome/hg38/Sanger
    wget -P resources/ref_genome/hg38/Sanger -c https://ftp.sanger.ac.uk/pub/cancer/dockstore/human/GRCh38_hla_decoy_ebv/SNV_INDEL_ref_GRCh38_hla_decoy_ebv-fragment.tar.gz
    wget -P resources/ref_genome/hg38/Sanger -c https://ftp.sanger.ac.uk/pub/cancer/dockstore/human/GRCh38_hla_decoy_ebv/CNV_SV_ref_GRCh38_hla_decoy_ebv_brass6+.tar.gz
    wget -P resources/ref_genome/hg38/Sanger -c https://ftp.sanger.ac.uk/pub/cancer/dockstore/human/GRCh38_hla_decoy_ebv/core_ref_GRCh38_hla_decoy_ebv.tar.gz
    wget -P resources/ref_genome/hg38/Sanger -c https://ftp.sanger.ac.uk/pub/cancer/dockstore/human/GRCh38_hla_decoy_ebv/VAGrENT_ref_GRCh38_hla_decoy_ebv_ensembl_91.tar.gz
    wget -P resources/ref_genome/hg38/Sanger -c https://ftp.sanger.ac.uk/pub/cancer/support-files/cgpPindel/cgpPindel_CPBI_refarea.tar.gz
    wget -P resources/ref_genome/hg38/Sanger -c https://ftp.sanger.ac.uk/pub/cancer/support-files/CPIB/caveman/cgpCaVEManWrapper_CPBI_refarea.tar.gz


    tar -zxvf resources/ref_genome/hg38/Sanger/SNV_INDEL_ref_GRCh38_hla_decoy_ebv-fragment.tar.gz -C resources/ref_genome/hg38/Sanger
    tar -zxvf resources/ref_genome/hg38/Sanger/CNV_SV_ref_GRCh38_hla_decoy_ebv_brass6+.tar.gz -C resources/ref_genome/hg38/Sanger
    tar -zxvf resources/ref_genome/hg38/Sanger/core_ref_GRCh38_hla_decoy_ebv.tar.gz -C resources/ref_genome/hg38/Sanger
    tar -zxvf resources/ref_genome/hg38/Sanger/VAGrENT_ref_GRCh38_hla_decoy_ebv_ensembl_91.tar.gz -C resources/ref_genome/hg38/Sanger
    ### copy coding snp and indel to 
    cp resources/ref_genome/hg38/Sanger/VAGrENT_ref_GRCh38_hla_decoy_ebv_ensembl_91/vagrent/gene_regions.bed* \
      resources/ref_genome/hg38/Sanger/SNV_INDEL_ref_GRCh38_hla_decoy_ebv-fragment/caveman/flagging/

    cp resources/ref_genome/hg38/Sanger/VAGrENT_ref_GRCh38_hla_decoy_ebv_ensembl_91/vagrent/codingexon_regions.sub.bed* \
      resources/ref_genome/hg38/Sanger/SNV_INDEL_ref_GRCh38_hla_decoy_ebv-fragment/caveman/flagging/

    touch build_log/hg38/download_sanger.log
else
    echo -e "${GREEN_B} already download CaVEMan,BRASS, continue ${NC}"
fi



### Download VEP data, version 110
echo "Beginning VEP config files  Download ..."
if [ ! -f "build_log/hg38/download_vep.log" ]; then
    mkdir -p resources/ref_genome/hg38/vep/v110
    wget -P resources/ref_genome/hg38/vep/v110 -c https://ftp.ensembl.org/pub/release-110/variation/indexed_vep_cache/homo_sapiens_vep_110_GRCh38.tar.gz

    tar -xzvf resources/ref_genome/hg38/vep/v110/homo_sapiens_vep_110_GRCh38.tar.gz -C resources/ref_genome/hg38/vep/
    touch build_log/hg38/download_vep.log
else
    echo -e "${GREEN_B} already download VEP cache ${NC}"
fi

### BWA index
echo "Beginning BWA genome index build ..."
if [ ! -f "resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta.amb" ]; then
    conda activate clindet 
    bwa index resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta
else
    echo -e "${GREEN_B} already built Genome BWA index for hg38 ${NC}"
fi

### do some mass config
conda activate clindet 
echo "Do some mass config ..."
if [ ! -f "build_log/hg38/mass_config.log" ]; then
    ### dbsnp bgzip
    bgzip -k -d -o resources/ref_genome/hg38/dbsnp_138.hg38.vcf resources/ref_genome/hg38/dbsnp_138.hg38.vcf.gz
    ### gatk CreateSequenceDictionary
    resources/softwares/gatk/gatk CreateSequenceDictionary -R resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta
    ### download delly
    touch build_log/hg38/mass_config.log
else
    echo -e "${GREEN_B} Some Mass configuration for hg38 finished ${NC}."
fi

# conda activate clindet
# mkdir -p resources/ref_genome/hg38/fasta
# faSplit byname resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta resources/ref_genome/hg38/fasta/
# head -n 24 resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta.fai > resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta.auto.fai


### STAR index
### RSME STAR index
conda activate clindet_rsem
echo "Beginning RSEM star indexing ..."
if [ ! -f "build_log/hg38/rsem_star_index.log" ]; then
    wget -P resources/ref_genome/hg38/ -c https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/gencode.v49.annotation.gtf.gz
    gzip -c -d resources/ref_genome/hg38/Homo_sapiens.GRCh38.114.chr.gtf.gz > resources/ref_genome/hg38/gencode.v49.annotation.gtf
    rsem-prepare-reference \
    --gtf resources/ref_genome/hg38/resources/ref_genome/hg38/Homo_sapiens.GRCh38.114.chr.gtf \
    --star -p 20 \
    resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta \
    resources/ref_genome/hg38/RSEM/hg38
    touch build_log/hg38/rsem_star_index.log
else
    echo -e "${GREEN_B} already built RSEM STAR index for hg38. ${NC}"
fi

conda activate clindet_rsem
echo "Beginning STAR indexing ..."
if [ ! -f "build_log/hg38/star_index.log" ]; then
    STAR \
    --runThreadN 20 \
    --runMode genomeGenerate \
    --genomeFastaFiles resources/ref_genome/hg38/GRCh38_masked_exclusions_alts_hlas.fasta \
    --sjdbOverhang 100 --genomeSAindexNbases 2 \
    --sjdbGTFfile resources/ref_genome/hg38/Homo_sapiens.GRCh38.114.chr.gtf \
    --genomeDir  resources/ref_genome/hg38/STAR/hg38 

    touch build_log/hg38/star_index.log
else
    echo -e "${GREEN_B} already built STAR index ${NC}"
fi

### build kallisto index
echo "Beginning kallisto & salmon indexing ..."
if [ ! -f "build_log/hg38/kallisto_salmon_index.log" ]; then
    wget -P resources/ref_genome/hg38/ -c https://ftp.ensembl.org/pub/release-114/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
    gzip -c -d resources/ref_genome/hg38/Homo_sapiens.GRCh38.cdna.all.fa.gz > resources/ref_genome/hg38/Homo_sapiens.GRCh38.cdna.all.fa
    mkdir -p resources/ref_genome/hg38/kallisto
    kallisto index -i resources/ref_genome/hg38/kallisto/hg38 resources/ref_genome/hg38/Homo_sapiens.GRCh38.cdna.all.fa -t 20
    ### build salmon index
    mkdir -p resources/ref_genome/hg38/salmon
    salmon index -t resources/ref_genome/hg38/Homo_sapiens.GRCh38.cdna.all.fa.gz -i resources/ref_genome/hg38/salmon/hg38

    touch build_log/hg38/kallisto_salmon_index.log
else
    echo -e "${GREEN_B} already built STAR index ${NC}"
fi

PWD=$(pwd)
echo " \n \n"
echo -e "The files for running the hg38 version of the genome have now been downloaded. Please modify and configure the settings in the config.yaml​ file according to the requirements in the help documentation."
echo -e "${GREEN_B} ${PWD} ${NC}"
