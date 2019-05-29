#!/bin/bash

## output mapping qc results

input_bam=$1
output_dir=$2


${SAMTOOLS_PATH}/samtools flagstat $input_bam > ${2}/qc_${MAPPING_METHOD}_flagstat.txt
${SAMTOOLS_PATH}/samtools idxstats $input_bam > ${2}/qc_${MAPPING_METHOD}_idxstat.txt


total_uniq_map=$(${SAMTOOLS_PATH}/samtools view -q 1 $input_bam | grep -v -e 'XA:Z' -e 'SA:Z:' | wc -l)  ## number of unique mapped reads
total_q10=$(${SAMTOOLS_PATH}/samtools view -q 10 $input_bam | wc -l)
total_q30=$(${SAMTOOLS_PATH}/samtools view -q 30 $input_bam | wc -l)


echo "total_uniq_map    $total_uniq_map" > ${2}/qc_${MAPPING_METHOD}_tmp.txt 
echo "total_q10 $total_q10" >> ${2}/qc_${MAPPING_METHOD}_tmp.txt 
echo "total_q30 $total_q30" >> ${2}/qc_${MAPPING_METHOD}_tmp.txt 

## using R to make the result as a table

