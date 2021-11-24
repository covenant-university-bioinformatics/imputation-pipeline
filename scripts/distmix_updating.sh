#!/usr/bin/env bash


### This Script is to preprocess user input file.
## version 0.1
## 01/06/2021
## maintainer  Yagoub Adam
## maintainer Dare
## maintainer
declare -i minimumFields=6

##### Directories 
bin_dir=".";
gwas_summary=$1;
output_dir=$2;
output=$3;



## Datasets
Reference_Panels=${bin_dir}/ref/1kg_geno_af1.gz; ## 1000 Genomes Phase1 Release3; Number of Samples 1092; Number of populations 14; Hg19
Reference_Index=${bin_dir}/ref/1kg_index.gz 
Populations_Weight=${bin_dir}ref/pop.wgt.txt;

##### Parameters
windowSize=$4;      # The size of the DIST prediction window (Mb).
wingSize=$5;        # The size of the area (wing) flanking the left and right of the DISTMIX prediction window (Mb).
chromosome=$6;      # positive integer between 1 and 22 or string such as "1p” or “2q"


#### log file and Output file
log=log.txt





##### Input file format, Dare will check this
### In case zscore is not provided, user has tow options:
     ## 1.  User shoud include  effect size (beta) and standard error (se); Z = (beta)/se
     ## 2. User shoud include  p-value and effect size (beta); Z= sign(Effect Size) * abs(qnorm(p-value/2)); where qnorm is the inverse cumulative distribution function  of the normal distribution.
     
### Required columns' names
# 1. rsid  
# 2. chr     # numerical
# 3. bp      # position
# 4. ref     # ref alele 
# 5. alt     # alternative alele 
# 6. z       # zscore
# 7. af1     # cohort reference allele frequency (RAF) --- Optional 
# 8. pvalue  # In case zscore is not provided 
# 9. beta    # In case zscore is not provided 
#10. se      # In case zscore is not provided 



#### set defulat Parameters

if [[ "$windowSize" -eq "" ]]; then
  windowSize=1.0;
fi

if [[ "$wingSize" -eq "" ]]; then
  wingSize=0.5;
fi

if [[ "$output" -eq "" ]]; then
  output="Output.txt";
fi

########## Get column indexes and check minimum fields number
read -r line < "$gwas_summary"     ## read first line from file into 'line'
oldIFS="$IFS"                                   ## save current Internal Field Separator (IFS)
IFS=$' '                                        ## set IFS to word-split on '\t'
fieldarray=($line);                             ## fill 'fldarray' with fields in line
IFS="$oldIFS"                                   ## restore original IFS
nfields=(${#fieldarray[@]})                     ## get number of fields in 'line'


if [[ "$nfields" -lt "$minimumFields" ]];   ## test against header
then
  echo "Please check your input file and try again. --File header Errors--";
  
fi

#### All checking steps are deleted as Dare will do it. 



#### check zscore filed and af1 are exist 

af1=$(echo $line |tr " " "\n"|grep -inx 'af1'| cut -d: -f1);  # Cohort reference allele frequency (RAF).
z=$(echo $line |tr " " "\n"|grep -inx 'z'| cut -d: -f1);      # Zscore column




###### estimate z score if it is not exist
if [[ $z -eq "" ]];
then
  Rscript --vanilla ${bin_dir}/z_estimates.R ${input_dir}/$gwas_summary
fi


##### check again for zcore 

read -r line < "$gwas_summary"     ## read first line from file into 'line'
z=$(echo $line |tr " " "\n"|grep -inx 'z'| cut -d: -f1);

if [[ $z -eq "" ]];
then
  echo "please provide:  z score, or beta and standard error, or beta and pvalue";
  exit 1;
fi


##### Imputation

## Senario 1: User has provided af1  (cohort reference allele frequency (RAF)).
if [[ $af1 != "" ]];
then
  if [[ $chr != "" ]];
  then
  ${bin_dir}/distmix -c $chr  $gwas_summary -o ${output_dir}/$output -r $Reference_Panels -i $Reference_Index
  exit 1;
fi
${bin_dir}distmix  $gwas_summary -o ${output_dir}/$output -r $Reference_Panels -i $Reference_Index
fi

## Senario 2: User has no  provided af1  (cohort reference allele frequency (RAF)).

if [[ "$af1" -eq "" ]];
then
  if [[ "$chr" != "" ]];
  then
  ${bin_dir}distmix -c $chr $gwas_summary -o ${output_dir}/$output -r $Reference_Panels -i $Reference_Index -w $Populations_Weight
  exit 1;
   fi
${bin_dir}distmix  $gwas_summary -o ${output_dir}/$output -r $Reference_Panels -i $Reference_Index -w $Populations_Weight
fi
