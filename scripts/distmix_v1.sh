#!/usr/bin/env bash

### Download https://github.com/Chatzinakos/DISTMIX2
# wget -c https://www.dropbox.com/sh/sw03zojcwzpdeed/AABcZex7EMLcnajiJV6kzBSsa/33kg_index.gz?dl=0
# wget -c https://www.dropbox.com/sh/sw03zojcwzpdeed/AAC7YUZZxg1I_AVKq1vV1dwla/33kg_geno.gz?dl=0
# wget -c https://www.dropbox.com/sh/r1q6q2cmg47lukw/AABSyMp-D6oJqLrJ3JeUWshQa/distmix2?dl=0


set -x;
##### Directories 

bin_dir="/mnt/d/distmix_impute";
db_dir="/mnt/d/distmix_impute"


gwas_summary=$1;
output_dir=$2;
output="imputation.txt";

##### Parameters
#distmix_version=$3 #{1,2}
allele_frequency_information_is_available=$3 #{true, false}
if [[ $allele_frequency_information_is_available = "false"  ]]; then
    ASW=$4  ### African Ancestry in Southwest US (AFR)
    CEU=$5  ### Utah residents (CEPH) with Northern and Western European ancestry (EUR)
    CHB=$6  ### Han Chinese in Beijing, China (ASN)
    CHS=$7  ### Southern Han Chinese (ASN)
    CLM=$8 ### Colombian in Medellin, Colombia (AMR)
    FIN=$9  ### Finnish in Finland (EUR)
    GBR=${10} ### British in England and Scotlant (EUR)
    IBS=${11} ### Iberian populations in Spain (EUR)
    JPT=${12} ### Japanese in Tokyo, Japan (ASN)
    LWK=${13} ### Luhya in Wenbuye, Kenya (AFR)
    MXL=${14} ### Mexican Ancestry from Los Angeles, USA (AMR)
    PUR=${15} ### Puerto Rican in Puerto Rico (AMR)
    TSI=${16}  ### Toscani in Italia (EUR)
    YRI=${17} ### Yoruba in Ibadan, Nigeria (AFR)

    

	touch $output_dir/pop.wgt
	 echo -e "pop\twgt" > $output_dir/pop.wgt

	 echo -e "ASW\t${ASW}" >> $output_dir/pop.wgt
	 echo -e "CEU\t${CEU}" >> $output_dir/pop.wgt
	 echo -e "CHB\t${CHB}" >> $output_dir/pop.wgt
	 echo -e "CHS\t${CHS}" >> $output_dir/pop.wgt
	 echo -e "CLM\t${CLM}" >> $output_dir/pop.wgt
	 echo -e "FIN\t${FIN}" >> $output_dir/pop.wgt
	 echo -e "GBR\t${GBR}" >> $output_dir/pop.wgt
	 echo -e "IBS\t${IBS}" >> $output_dir/pop.wgt
	 echo -e "JPT\t${JPT}" >> $output_dir/pop.wgt
	 echo -e "LWK\t${LWK}" >> $output_dir/pop.wgt
	 echo -e "MXL\t${MXL}" >> $output_dir/pop.wgt
	 echo -e "PUR\t${PUR}" >> $output_dir/pop.wgt
	 echo -e "TSI\t${TSI}" >> $output_dir/pop.wgt
	 echo -e "YRI\t${YRI}" >> $output_dir/pop.wgt


    
    
    
   Populations_Weight=$output_dir/pop.wgt 
   chromosome=${18};  #{all, 1-22}
   windowSize=${19};      # The size of the DIST prediction window (Mb).
   wingSize=${20};

else
    chromosome=$4; #{all, 1-22}
    windowSize=$5;      # The size of the DIST prediction window (Mb).
    wingSize=$6;        # The size of the area (wing) flanking the left and right of the DISTMIX prediction window (Mb).
       
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



#### set default Parameters



if [[ -z "$windowSize" ]];  then
  windowSize=1.0; 
fi

if [[ -z "$wingSize"  ]]; then  
   wingSize=0.5;
fi



##### Imputation


cmd=''
if [[ ${allele_frequency_information_is_available} = "true" ]] && [[ ${chromosome} != "all" ]]; then
       cmd="-c $chromosome "
elif [[ ${allele_frequency_information_is_available} = "true" ]] && [[  ${chromosome} = "all" ]]; then 
       cmd=''
elif [[  ${allele_frequency_information_is_available} = "false" ]] && [[ ${chromosome} != "all" ]]; then 
       cmd="-w $Populations_Weight -c ${chromosome} "
elif [[ ${allele_frequency_information_is_available} = "false" ]] && [[ ${chromosome} = "all" ]]; then 
     cmd="-w $Populations_Weight  "
fi    


#./distmix_v1.sh sample.input.chr22.txt output false 0.101 0.14 0.14 0.025 0.08 0.09 0.139 0.0 0.09 0.011 0.09 0.03 0.009 0.189 22
#./distmix_v1.sh sample.input.chr22.wthAf1.txt output true 22

 ${bin_dir}/distmix  $gwas_summary  ${cmd} -o ${output_dir}/$output \
    -r ${db_dir}/ref/1kg_geno_af1.gz  -i ${db_dir}/ref/1kg_index.gz  \
    -n ${windowSize} -m ${wingSize}

