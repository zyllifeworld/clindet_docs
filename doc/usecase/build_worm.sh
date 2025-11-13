set -euo pipefail
RED='\e[31m'
RED_B='\e[41m'
NC='\e[0m'
GREEN='\e[32m'
GREEN_B='\e[42m'
bold='\e[1;43m'
mkdir -p build_log

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
mkdir -p resources/ref_genome/WBcel235

## Download WBcel235 genome fasta and GTF (without chr prefix)
## http://ftp.ensemblgenomes.org/pub/metazoa/release-62/fasta/caenorhabditis_elegans/dna/
# https://metazoa.ensembl.org/info/data/ftp/index.html
conda activate clindet
echo "Beginning WBcel235 genome fasta & GTF Download ..."
if [ ! -f "build_log/download_WBcel235.log" ]; then
    echo "Start download from ensembl ..."
    wget -P resources/ref_genome/WBcel235/ https://ftp.ensembl.org/pub/release-114/fasta/caenorhabditis_elegans/dna/Caenorhabditis_elegans.WBcel235.dna.toplevel.fa.gz
    wget -P resources/ref_genome/WBcel235/ https://ftp.ensembl.org/pub/release-114/fasta/caenorhabditis_elegans/cdna/Caenorhabditis_elegans.WBcel235.cdna.all.fa.gz
    wget -P resources/ref_genome/WBcel235/ https://ftp.ensembl.org/pub/release-114/fasta/caenorhabditis_elegans/ncrna/Caenorhabditis_elegans.WBcel235.ncrna.fa.gz
    wget -P resources/ref_genome/WBcel235/ https://ftp.ensembl.org/pub/release-114/gtf/caenorhabditis_elegans/Caenorhabditis_elegans.WBcel235.114.gtf.gz
    gzip -dc resources/ref_genome/WBcel235/Caenorhabditis_elegans.WBcel235.dna.toplevel.fa.gz > resources/ref_genome/WBcel235/WBcel235_genome.fa
    # gzip -dc resources/ref_genome/WBcel235/Caenorhabditis_elegans.WBcel235.62.gtf.gz > resources/ref_genome/WBcel235/Caenorhabditis_elegans.WBcel235.62.gtf
    gzip -dc resources/ref_genome/WBcel235/Caenorhabditis_elegans.WBcel235.114.gtf.gz > resources/ref_genome/WBcel235/Caenorhabditis_elegans.WBcel235.114.gtf


    resources/softwares/gatk/gatk CreateSequenceDictionary -R resources/ref_genome/WBcel235/WBcel235_genome.fa
    samtools faidx resources/ref_genome/WBcel235/WBcel235_genome.fa
    echo "Done"
    touch build_log/download_WBcel235.log
else
    echo -e "${GREEN_B} already download WBcel235 reference, continue ${NC}"
fi

### Download VEP data, version v113, latest version since 2025/09
echo "Beginning VEP config files  Download ..."
if [ ! -f "build_log/download_vep_WBcel235.log" ]; then

    mkdir -p resources/ref_genome/WBcel235/vep/v113
    wget -P resources/ref_genome/WBcel235/vep/v113 -c https://ftp.ensembl.org/pub/release-113/variation/vep/caenorhabditis_elegans_vep_113_WBcel235.tar.gz

    tar -xzvf resources/ref_genome/WBcel235/vep/v113/caenorhabditis_elegans_vep_113_WBcel235.tar.gz -C resources/ref_genome/WBcel235/vep/
    touch build_log/download_vep_WBcel235.log
else
    echo -e "${GREEN_B} already download VEP cache ${NC}"
fi

### BWA index
echo "Beginning BWA genome index build ..."
if [ ! -f "resources/ref_genome/WBcel235/WBcel235_genome.fa.amb" ]; then
    conda activate clindet 
    bwa index resources/ref_genome/WBcel235/WBcel235_genome.fa
else
    echo -e "${GREEN_B} already built Genome BWA index ${NC}"
fi


