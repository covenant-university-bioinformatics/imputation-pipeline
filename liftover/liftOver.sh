#!/usr/bin/env bash


### This Script is to preprocess user input file.
## version 0.1
## 01/06/2021
## maintainer  Yagoub Adam
## maintainer Dare
## maintainer
## To run it ./liftOver.sh gwas_summary NCBI_build{38/36}

##### Parameters
gwas_summary=$1;
NCBI_build=$2;     # For liftOver
outputdir=$3     ## I think no need it as an input agrument
liftOver_output=liftedOver.txt;
liftOver_data=".";


#### input file is preprocessed by Dare, such as
   ####1st column is chr
   ####2nd column is pos
   ####3rd column is rsid


#### creating liftOver input file, i.e. bed file
    ####1st column is chr (start by chr)
    ####2nd column is start pos
    ####3rd column is end pos (start pos +1)
    ####4th column is rsid
    ####5th column is chr (orginal numerical value )


awk '{print "chr"$1"\t"$2"\t"($2+1)"\t"$3"\t"$1}' $gwas_summary >  dbsnp.bed ## rearranges the columns
sed -i '1d' dbsnp.bed   #remove header



############ liftOver 38,

if [[ $NCBI_build -eq 38 ]];
then
## Do liftOver from NCBI 38 (hg38) to hg 19 (NCBI 37)
## We safe liftOver binnary file in the root folder
liftOver dbsnp.bed $liftOver_data/hg38ToHg19.over.chain.gz output-lifted.bed unlifted.bed # we report both outputs

fi

if [[ $NCBI_build -eq 36 ]];
then
## Do liftOver  NCBI 36 (hg18) to hg 19 (NCBI 37)
liftOver dbsnp.bed $liftOver_data/hg18ToHg19.over.chain.gz   output-lifted.bed unlifted.bed # we report both outputs

fi

#### Merge liftOver output with user input file
    #### Merge two files based on rsid
    ##### makes 2nd column as pos
    ##### makes 3rd column as rsid
    ##### makes 1st column as chr   (orginal numerical value)
    ##### Remove unneeded files

  join  -1 4 -2 3 <(sort -k 4 output-lifted.bed) <( sort  -k3 $gwas_summary) | awk '{$2=$3;$3=$1;$1=$5; $4=$5=$6=$7=""; print $0}' | sed 's/ \+/ /g'> temp_final.txt


## Retreive header

head -n 1 $gwas_summary > $liftOver_output
cat temp_final.txt >> $liftOver_output

rm temp_final.txt;
