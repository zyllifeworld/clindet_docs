(install)=

# Setup Clindet

## install conda, Docker and SingularityCE

To build the complex Clindet analysis environment, you need to install `Conda` and `SingularityCE`.

## Install ClinDet
### clone clinDet from github

```bash
git clone https://github.com/zyllifeworld/clindet.git
cd clindet
```
### Run build_conda_env.sh 

Clindet provides a bash script to set up the computational environment required for running the software, as well as to download configuration files needed for various tools that use the human b37 reference genome (e.g., VCF, BED files). Run the script `build_conda_env.sh` to complete this setup, This script will download approximately **~170 GB** of files. Please ensure you have sufficient available space.

### Modify the config.yaml file
Update the placeholder `/AbsoPath/of/clindet/folder` in **clindet/workflow/config/config_local_test.yaml** file to your actual Clindet directory path (e.g., `/home/users/softwares/clindet`) and then save the file as config.yaml.

#### generate a BED of gene exomes for WES analysis 
you can use the GTF to generate a BED file, contains four columns **chr**,**start**,**end**,**gene_name** (*optional), bellow is an example:
```bash
1       11858   12237   DDX11L1
1       12602   12731   DDX11L1
1       12964   13062   DDX11L1
1       13210   14511   DDX11L1;WASH7P
```
ClinDet provides a [reference BED](../usecase/b37_gene.bed) file for the b37 genome version (for Use Case I). You can modify this configuration according to your own requirements. Alternatively, you can use our provided script [gtf2bed.R](../utils/gtf2bed.R) to convert gene annotation GTF files to the BED format.

**You are now ready to start your analysis tasks!**