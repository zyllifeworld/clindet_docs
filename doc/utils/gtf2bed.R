#Load required libraries
library(rtracklayer)
library(tidyverse)

# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if exactly two arguments are provided
if (length(args) != 2) {
  stop("Usage: Rscript gtf_to_bed.R <input_gtf_path> <output_bed_path>")
}

# Assign arguments to variables
gtf_path <- args[1]
output_path <- args[2]

# Read GTF file
gtf <- import(gtf_path)
exon_gtf <- gtf[gtf$type == 'exon']

# Convert to data frame
exon_df <- as.data.frame(exon_gtf)

# Select and filter relevant columns
## chromosome without chr prefix
# c(1:22, 'X', 'Y', 'MT')
## chromosome with chr prefix
# str_c('chr',c(1:22, 'X', 'Y', 'M'))
exon_bed_df <- exon_df %>%
  select(seqnames, start, end, gene_name) %>%
  filter(seqnames %in% c(c(1:22, 'X', 'Y', 'MT'),str_c('chr',c(1:22, 'X', 'Y', 'M'))))

## check BED files with width > 1 and sort
exon_bed_df[which((exon_bed_df$end - exon_bed_df$start) <=3),]
exon_bed_df %>% arrange(seqnames,start)
# Write to BED format without column names
write_delim(exon_bed_df, file = output_path, col_names = FALSE, delim = "\t")