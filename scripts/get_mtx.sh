#!/bin/bash

### will search bam file under ouptu_dir/mapping_resutl
set -e
input_peaks=$1

# reading configure file
curr_dir=`dirname $0`
source ${curr_dir}/read_conf.sh
read_conf "$2"
read_conf "$3"

mat_dir="${OUTPUT_DIR}/raw_matrix"
mkdir -p $mat_dir

input_bam=${OUTPUT_DIR}/mapping_result/${OUTPUT_PREFIX}.${MAPPING_METHOD}.positionsort.MAPQ${MAPQ}.bam

ncore=$(nproc --all)
ncore=$(($ncore - 1))



curr_dir=`dirname $0`
if [[ ! -f ${mat_dir}/fragments.bed ]]; then
    #echo "Converting bam to sam"
    #${SAMTOOLS_PATH}/samtools view -h -@ $ncore  $input_bam > ${mat_dir}/tmp.sam
    echo "Getting bed file for read pair (fragment) information"
   #${PERL_PATH}/perl ${curr_dir}/src/simply_sam2frags.pl --read_file ${mat_dir}/tmp.sam  --output_file ${mat_dir}/fragments.bed
   ${PERL_PATH}/perl ${curr_dir}/src/simply_bam2frags.pl --read_file $input_bam \
        --output_file ${mat_dir}/fragments.bed --samtools_path $SAMTOOLS_PATH

fi

#echo "Sorting the output by position" -- slow in shell, just do it by R will be much faster
#sort -k1,1 -k2,2n -k3,3n ${mat_dir}/fragments.bed > ${mat_dir}/fragments.bed.sorted



echo "Getting peak by barcode matrix..."
# this R script will output sorted fragments as well
${R_PATH}/R --vanilla --args ${mat_dir}/fragments.bed $input_peaks ${mat_dir}/${OUTPUT_PREFIX}.${MAPPING_METHOD}.peak.barcode.mtx < ${curr_dir}/src/get_mtx.R 

if [[ $BIN_RESL != '' ]]; then
    echo "Getting bin by barcode matrix as well ..."
    bin_file=${mat_dir}/${OUTPUT_PREFIX}_bin.bed
    bin_dir=${mat_dir}/bin_mat_resl${BIN_RESL}
    mkdir -p $bin_dir
    ${BEDTOOLS_PATH}/bedtools makewindows -g $CHROM_SIZE_FILE -w $BIN_RESL > $bin_file
    ${R_PATH}/R --vanilla --args ${mat_dir}/fragments.bed $bin_file ${bin_dir}/${OUTPUT_PREFIX}.${MAPPING_METHOD}.bin_resl${BIN_RESL}.mtx < ${curr_dir}/src/get_mtx.R 
    rm $bin_file
fi


#rm ${mat_dir}/tmp.sam

echo "Get Matrix Done!"






