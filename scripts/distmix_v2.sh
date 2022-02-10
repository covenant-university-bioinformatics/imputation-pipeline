#!/usr/bin/env bash

### Download https://github.com/Chatzinakos/DISTMIX2
# wget -c https://www.dropbox.com/sh/sw03zojcwzpdeed/AABcZex7EMLcnajiJV6kzBSsa/33kg_index.gz?dl=0
# wget -c https://www.dropbox.com/sh/sw03zojcwzpdeed/AAC7YUZZxg1I_AVKq1vV1dwla/33kg_geno.gz?dl=0
# wget -c https://www.dropbox.com/sh/r1q6q2cmg47lukw/AABSyMp-D6oJqLrJ3JeUWshQa/distmix2?dl=0


set -x;
##### Directories 
bin_dir="/home/yagoubali/Projects/deployment/imputation-pipeline/scripts";
db_dir="/media/yagoubali/bioinfo2/pgwas/impute2"
gwas_summary=$1;
output_dir=$2;
output="imputation.txt";

##### Parameters
distmix_version=$3 #{1,2}
allele_frequency_information_is_available=$4 #{true, false}
if [[ $allele_frequency_information_is_available = "false"  ]]; then
    AFR_weight=$5
    AMR_weight=$6
    EAS_weight=$7
    EUR_weight=$8
    SAS_weight=$9
    
    touch $output_dir/pop.wgt    
    echo -e "Super_Pop\tWgt" > $output_dir/pop.wgt
    echo -e "AFR\t${AFR_weight}" >> $output_dir/pop.wgt
    echo -e "AMR\t${AMR_weight}" >> $output_dir/pop.wgt
    echo -e "ASN\t${EAS_weight}" >> $output_dir/pop.wgt
    echo -e "EUR\t${EUR_weight}" >> $output_dir/pop.wgt
    echo -e "SAS\t${SAS_weight}" >> $output_dir/pop.wgt
   Populations_Weight=$output_dir/pop.wgt 
   chromosome=${10};  #{all, 1-22}
   windowSize=${11};      # The size of the DIST prediction window (Mb).
   wingSize=${12};
           # The size of the area (wing) flanking the left and right of the DISTMIX prediction window (Mb).
   if  [[  $distmix_version = 2 ]] ; then
        measured_snps=${13}
       if [[ -z "$measured_snps" ]]; then
           measured_snps=500;
        fi
   fi
   
else
    chromosome=$5; #{all, 1-22}
    windowSize=$6;      # The size of the DIST prediction window (Mb).
    wingSize=$7;        # The size of the area (wing) flanking the left and right of the DISTMIX prediction window (Mb).
    
   if [[  $distmix_version = 2 ]]; then
       measured_snps=$8
       if [[ -z "$measured_snps" ]]; then
           measured_snps=500;
       fi
   fi
       
fi



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
# 7. af     # cohort reference allele frequency (RAF) --- Optional 
# 8. pvalue  # In case zscore is not provided 
# 9. beta    # In case zscore is not provided 
#10. se      # In case zscore is not provided 


#### set defulat Parameters

if [[ -z "$windowSize" ]] && [[  $distmix_version = 2 ]];  then
  windowSize=0.5;
elif [[ -z "$windowSize" ]] && [[  $distmix_version = 1 ]];  then
  windowSize=1.0; 
fi

if [[ -z "$wingSize"  ]] && [[  $distmix_version = 2 ]]; then
  wingSize=0.25;
elif [[ -z "$wingSize"  ]] && [[  $distmix_version = 1 ]]; then  
   wingSize=0.5;
fi



##### Imputation
### 4 senarios 
###  ->1 User provided af  (cohort reference allele frequency (RAF)) && provided chromosome
###  ->2 User provided af  (cohort reference allele frequency (RAF)) && !provided chromosome (impute all chromosomes)
###  ->3 User !provided af  (cohort reference allele frequency (RAF)) && provided chromosome
###  ->4 User !provided af1 (cohort reference allele frequency (RAF)) && !provided chromosome (impute all chromosomes)

cmd=''
if [[ $af != "" ]] && [[ $chr != "" ]]; then
       cmd="-c $chr "
elif [[ $af != "" ]] && [[  $chr = "all" ]]; then 
       cmd=''
elif [[ -z "$af" ]] && [[ $chr != "" ]]; then 
       cmd="-w $Populations_Weight -c $chr "
elif [[ -z "$af" ]] && [[ $chr = "all" ]]; then 
     cmd="-w $Populations_Weight  "
fi    


#./distmix_v2.sh sample.input.chr22.txt output 2 false 0.6 0.2 0.1 0.1 0.0 22
#./distmix_v2.sh sample.input.chr22.wthAf1.txt 2 output true 22
#./distmix_v2.sh sample.input.chr22.txt output 1 false 0.6 0.2 0.1 0.1 0.0 22
#./distmix_v2.sh sample.input.chr22.wthAf1.txt output 1 true 22

if  [[  $distmix_version = 2 ]]; then
     ${bin_dir}/distmix2  $gwas_summary ${cmd} -x ${output_dir}/$output \
     -r ${db_dir}/ref/33kg_geno.gz -i ${db_dir}/ref/33kg_index.gz  \
     -n ${windowSize} -m ${wingSize} -j ${measured_snps}
elif  [[  $distmix_version = 1 ]]; then
    ${bin_dir}distmix  $gwas_summary  ${cmd} -o ${output_dir}/$output \
    -r ${db_dir}/ref/1kg_geno.gz  -i ${db_dir}/ref/1kg_index.gz  \
    -n ${windowSize} -m ${wingSize}
fi
