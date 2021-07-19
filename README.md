# imputation_pipeline
## Imputation of summary statistics for unmeasured SNPs
## Column names
[//]: -------------------------------
- Column names are automatically recognised using commonly used names. See subsection below.
- Users  need to be provided:  SNP-id, reference allel, effect allele,  Position, Chromosome, ad  Z-statistic 
- In case  Z-statistic not provided the following 3 fields are compulsory: P-value,log-transformed into effect sizes and Standard error.
- users can provide optionally Cohort reference allele frequency (RAF).
- Positions should match the positions in the reference panel as NCBI build 37 (e.g. both hg19). 
- If case positions in the GWAS file do not match the reference panel positions, use use LiftOver as a command line tool: http://genome.ucsc.edu/cgi-bin/hgLiftOver.

### Automatic header recognition

- Column names  are not case sensitive. E.g. P-value column can be named `p` or `P`.
- **SNP-id** should be named: 	`ID`, `rnpid`, `snpid`, `rsid`, `MarkerName`, `snp` or `marker`.
- **Chromosome** should be named: `chr`, `chromosome`, `chrm` or `CHROM`.
- **Position** should be named: `POS`,`position` or` `BP`.
- **reference allele** should be named: `REF`, `a1`, `Allele1`, `AlleleA` or `other_allele`.
- **effect allele** should be named: `ALT`, `a2`, `Allele2`, `AlleleB` or `effect_allele`.
- **Z-statistic** should be named: `z`, `zscore`, `stat`, `z_score` or `z.score`. 
- **Pvalue** should be named: `p`, `P-value`, `P.value`, `PVALUE`, or `normal.score.p`.
- **Effect size** should be named: `b`, `beta`, `ALT_EFFSIZE`,  or `normal.score.beta`.
- **Standard error** should be named: `se`, or `normal.score.se`.
- **Cohort reference allele frequency (RAF)** should be named: `af1`
