#!/usr/bin/env bash


### This Script is to preprocess user input file.
## version 0.1
## 01/06/2021
## maintainer  Yagoub Adam
## maintainer Dare
## maintainer
declare -i minimumFields=6
## Datasets
rep_path=~/distmix/ref;
populationWeight=~/distmix/ref/pop.wgt.txt;

##### Parameters
gwas_summary=$1;
chromosome=$3; # positive integer between 1 and 22 or string such as "1p” or “2q"
windowSize=$4; #The size of the DIST prediction window (Mb).
wingSize=$5;  #The size of the area (wing) flanking the left and right of the DISTMIX prediction window (Mb).

## log file and Output file

log=log.txt
output=$2
cleanedGWAS=temp.txt
#####

## ## set defulat Parameters
if [[ "$windowSize" -eq "" ]]; then
  windowSize=1.0;
fi

if [[ "$wingSize" -eq "" ]]; then
  wingSize=0.5;
fi

if [[ "$output" -eq "" ]]; then
  output="Output.txt";
fi

function error_exit(){
  printf " Your input file should contain at least 6 columns, which are:\n \
  1-  SNP-id:  its name should be  named snpid. \n \
  2. reference allele: Its name should be  named REF.\n \
  3. effect allele:  Its name should be  named ALT. \n  \
  4. Position:  Its name should be  named  POS.\n \
  5. Chromosome:  Its name should be  named chrm. \n  \
  6.  Z-statistic should be named zscore. \n \
  \n \
  ### In case  Z-statistic not provided the following 3 fields are compulsory: \n \
  \n \
  7. P-value: Its name should be  named p.value. \n \
  8. Effect size: Its name should be  named  beta. \n \
  9. Standard error: Its name should be  named se.\n \
  \n";
exit 1;
}

########## check arguments

if [[ $# -lt 1 ]]; then
  echo "Please check your input file and try again.";
  error_exit;
fi

########## check Input file

if [[ ! -f "$gwas_summary" ]]; then
    echo "$gwas_summary is not a regular file. Please check your file and try again.";
    exit;
fi

########## Get column indexes and check minimum fields number
read -r line < "$gwas_summary"     ## read first line from file into 'line'
oldIFS="$IFS"           ## save current Internal Field Separator (IFS)
IFS=$' '               ## set IFS to word-split on '\t'
fieldarray=($line);     ## fill 'fldarray' with fields in line
IFS="$oldIFS"           ## restore original IFS
nfields=(${#fieldarray[@]}) ## get number of fields in 'line'

echo "nfields = "$nfields
echo $minimumFields
head $gwas_summary
echo "$nfields"
if [[ "$nfields" -lt "$minimumFields" ]];   ## test against header
then
  echo "Please check your input file and try again. --File header Errors--";
  #error_exit;
fi

## Get column indexes

rsid=$(echo $line |tr " " "\n"|grep -inx 'ID\|rnpid\|snpid\|rsid\|MarkerName\|snp\|marker'| cut -d: -f1);
chr=$(echo $line |tr " " "\n"|grep -inx 'chr\|chromosome\|chrm\|CHROM'| cut -d: -f1);
bp=$(echo $line |tr " " "\n"|grep -inx 'POS\|position\|BP'| cut -d: -f1);
ref=$(echo $line |tr " " "\n"|grep -inx 'REF\|a1\|Allele1\|AlleleA\|other_allele'| cut -d: -f1);
alt=$(echo $line |tr " " "\n"|grep -inx 'ALT\|a2\|Allele2\|AlleleB\|effect_allele'| cut -d: -f1);
pvalue=$(echo $line |tr " " "\n"|grep -inx 'p\|P-value\|P.value\|PVALUE\|normal.score.p\|pvalue'| cut -d: -f1);
beta=$(echo $line |tr " " "\n"|grep -inx 'b\|beta\|ALT_EFFSIZE\|normal.score.beta'| cut -d: -f1);       #Effect size
se=$(echo $line |tr " " "\n"|grep -inx 'se\|normal.score.se'| cut -d: -f1);         #Standard error
af1=$(echo $line |tr " " "\n"|grep -inx 'af1'| cut -d: -f1);  #(cohort reference allele frequency (RAF)).
z=$(echo $line |tr " " "\n"|grep -inx 'z\|zscore\|z_score\|z.score\|stat'| cut -d: -f1);  #(cohort reference allele frequency (RAF)).
### echo columns indexes

echo " rsid is $rsid index";
echo " chr is $chr index";
echo " bp is $bp index";
echo " ref is $ref index";
echo " alt is $alt index";
echo " pvalue is $pvalue index";
echo " beta is $beta index";
echo " se is $se index";
echo " af1 is $af1 index";
echo " z is $z index";


### rename colums

declare -a field_names

if [[ $rsid != "" ]];
then
  field_names[$rsid-1]=rsid;

fi

if [[ $chr != "" ]];
then
    field_names[$chr-1]=chr;
fi

if [[ $bp != "" ]];
then
  field_names[$bp-1]=bp;
fi

if [[ $ref != "" ]];
then
  field_names[$ref-1]=a1;
fi

if [[ $alt != "" ]];
then
  field_names[$alt-1]=a2;
fi

if [[ $pvalue != "" ]];
then
  field_names[$pvalue-1]=pvalue;
fi

if [[ $beta != "" ]];
then
  field_names[$beta-1]=beta;
fi

if [[ $se != "" ]];
then
  field_names[$se-1]=se;
fi

if [[ $af1 != "" ]];
then
  field_names[$af1 -1]=af1;
fi

if [[ $z != "" ]];
then
  field_names[$z -1]=z;
fi

echo  " We renaming your file's header "
echo " New header is ..."
echo " ${field_names[*]}"
echo " ${field_names[*]}"> $cleanedGWAS;
indexes2=$(echo "$rsid,$chr,$bp,$ref,$alt,$pvalue,$beta,$se,$af1,$z" | sed 's/,\{2,\}/,/g');
indexes=$(echo "${indexes2[*]}" | sed 's/,$//g');


cut -d " " -f $indexes $gwas_summary >  temp2.txt; # Just to dete this temp2 after getting headr
sed '1d' temp2.txt >> $cleanedGWAS;
rm temp2.txt

###### estimate z score if it is not exist
if [[ $z -eq "" ]];
then
  Rscript --vanilla z_estimates.R $cleanedGWAS
fi

read -r line < "$cleanedGWAS"     ## read first line from file into 'line'
z=$(echo $line |tr " " "\n"|grep -inx 'z'| cut -d: -f1);

if [[ $z -eq "" ]];
then
  echo "please provide:  z score, or beta and standard error, or beta and pvalue";
  exit 1;
fi


### Imputation

## Senario 1: User has provided af1  (cohort reference allele frequency (RAF)).
if [[ $af1 != "" ]];
then
  if [[ $chr != "" ]];
  then
  distmix -c $chr  $cleanedGWAS -o $output -r $rep_path/1kg_geno_af1.gz -i $rep_path/1kg_index.gz
  exit 1;
fi
distmix  $cleanedGWAS -o $output -r $rep_path/1kg_geno_af1.gz -i $rep_path/1kg_index.gz
fi

## Senario 2: User has no  provided af1  (cohort reference allele frequency (RAF)).

if [[ "$af1" -eq "" ]];
then
  if [[ "$chr" != "" ]];
  then
  distmix -c $chr  $cleanedGWAS -o $output -r $rep_path/1kg_geno_af1.gz -i $rep_path/1kg_index.gz -w $populationWeight
  exit 1;
   fi
distmix  $cleanedGWAS -o $output -r $rep_path/1kg_geno_af1.gz -i $rep_path/1kg_index.gz -w $populationWeight
fi
