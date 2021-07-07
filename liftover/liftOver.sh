#!/usr/bin/env bash


### This Script is to preprocess user input file.
## version 0.1
## 01/06/2021
## maintainer  Yagoub Adam
## maintainer Dare
## maintainer
declare -i minimumFields=6


##### Parameters
gwas_summary=$1;
NCBI_build=$2;     # For liftOver
outputdir=$3     ## I think no need it as an input agrument
liftOver_output=liftedOver.txt;
liftOver_data=".";



#####

function error_exit(){
  printf " Your input file should contain at least 6 Columns, which are:\n \
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
\n \
  ## The following filed is optional \n \
  10. Sample size:  Its name should be named n.\
  \n
  ";
exit 1;
}


if [[ $# -lt 1 ]]; then
  echo "Please check your input file and try again.";
  error_exit;
fi



### Output dir @dare

if [ ! -f "$gwas_summary" ]; then
    echo "$gwas_summary is not a regular file. Please check your file and try again.";
    exit;
fi

fields=("snpid"
         "REF"
         "ALT"
         "POS"
         "chrm"
         "zscore"
         "p.value"
         "beta"
         "se"
         "n" );

### In case the user does not provide REF and ALT no need to perfom Imputation analysis


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


## The below code is delted
#### Convert the array to an associate array to get the index of each Column
#array_i=0
#while [[ "$array_i" -lt "${#fieldarray[@]}" ]]; do
#      header_mapper[${fieldarray[$array_i]}] = $array_i
#      echo "${fieldarray[$array_i]}"
#   ((array_i++))
#done


# If Number of colums is 6, the file should has Z score fields

echo "${fieldarray[5]}"

if [[ "$nfields" -eq "$minimumFields"  &&  "${fieldarray[5]}" != "zscore" ]];   ## test against header
then
  echo "Z-score field is missing";
  #error_exit;
fi

## I have if zscore if missing

### To Do
 ## removes all lines that have an empty field in any column


############ liftOver 38,

if [[ $NCBI_build -eq 38 ]];
then
## transform
awk '{print "chr"$5"\t"$4"\t"($4+1)"\t"$1"\t"$5}' $gwas_summary > tmp.bed ## rearranges the columns
awk -F'\t' 'x$2' tmp.bed > dbsnp.bed  ## removes lines that have an empty field in the second column, i.e genomic corrdinate #
rm tmp.bed
grep -v chrchrm dbsnp.bed > dbsnp2.bed  # rm header
rm dbsnp.bed
## Do liftOver
## We safe liftOver binnary file in the root folder
liftOver dbsnp2.bed $liftOver_data/hg38ToHg19.over.chain.gz output-lifted.bed unlifted.bed # we report both outputs


## Merge Data
#awk can be used to print the common lines in two files.
#awk 'FNR==NR{a[$4]=$4;next}{if(a[$4]== $1); print $0}' output-lifted.bed $gwas_summary > tem_imputation_input.txt
join  -1 4 -2 1 <(sort -k 4 output-lifted.bed) <( sort  -k1 $gwas_summary) | awk '{$8=$3;$2=$3=$4=$5=""; print $0}' | sed 's/ \+/ /g'> temp_imputation_input.txt

fi

if [[ $NCBI_build -eq 36 ]];
then
## transform
awk '{print "chr"$5"\t"$4"\t"($4+1)"\t"$1"\t"$5}' $gwas_summary > tmp.bed ## rearranges the columns
awk -F'\t' 'x$2' tmp.bed > dbsnp.bed  ## removes lines that have an empty field in the second column, i.e genomic corrdinate #
rm tmp.bed
grep -v chrchrm dbsnp.bed > dbsnp2.bed  # rm header
rm dbsnp.bed
## Do liftOver
liftOver dbsnp2.bed $liftOver_data/hg38ToHg19.over.chain.gz  output-lifted.bed unlifted.bed # we report both outputs

## Merge Data
#awk 'FNR==NR{a[$4]=$4;next}{if(a[$4]== $1); print $0}' output-lifted.bed $gwas_summary > temp_imputation_input.txt
join  -1 4 -2 1 <(sort -k 4 output-lifted.bed) <( sort  -k1 $gwas_summary) | awk '{$8=$3;$2=$3=$4=$5=""; print $0}' | sed 's/ \+/ /g'> temp_imputation_input.txt


fi

## Retreive header

head -n 1 $gwas_summary > $liftOver_output
cat temp_imputation_input.txt >> $liftOver_output

rm temp_imputation_input.txt;
