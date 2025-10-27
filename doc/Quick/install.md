(install)=

# Setup Clindet

## install conda, Docker and SingularityCE

To build the complex Clindet analysis environment, you need to install Conda, Docker, and SingularityCE.

## Install Clindet
### clone clindet from github

```bash
git clone https://github.com/zyllifeworld/clindet.git
cd clindet
```
### Run build_conda_env.sh 

Clindet provides a bash script to set up the computational environment required for running the software, as well as to download configuration files needed for various tools that use the human b37 reference genome (e.g., VCF, BED files). Run the script build_conda_env.sh to complete this setup.

### Modify the config.yaml file
Replace the placeholder '/AbsoPath/of/clindet/folder' in the **clindet/workflow/config/config_local_test.yaml** file located in the Clindet software directory with the absolute path to your Clindet folder, for example: /home/users/softwares/clindet. save the modified file as config.yaml.

#### generate a BED of gene exomes for WES analysis 
you can use the GTF to generate a BED file, contains four columns chr,start,end,gene_name(*optional), bellow is an example:
```bash
1       11858   12237   DDX11L1
1       12602   12731   DDX11L1
1       12964   13062   DDX11L1
1       13210   14511   DDX11L1;WASH7P
```
ClinDet provides a example `b37` genome version bed file for use case I. You can adjust this config 依据 your own need.


**You are now ready to start your analysis tasks!**