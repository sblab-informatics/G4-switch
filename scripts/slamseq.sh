#!/bin/bash

conda activate slamseq

ref_fasta=hg38_selected.fa
bed_3primeUTR=gencode.v37.3primeUTR.bed
prom_500_v37=gencode.v37.TSSminus500.bed
output_dir=/scratchb/sblab/dhir01/Projects/Xiaoyun/SLX-21770/
mkdir $output_dir
fq_dir=/scratchb/sblab/dhir01/Projects/Xiaoyun/SLX-21770/fastq


#=================

for file in *gz
do
echo $file
sbatch --time 36:00:00 -e %j.$file.err -J 'slam'  --mem 22G --wrap "slamdunk all -r $ref_fasta -b $bed_3primeUTR -t 5 -5 12 -n 100 -m -mv 0.2 -c 2 -rl 100 $fq_dir/$file -o $output_dir --skip-sam "
done

#=================

# collapse counts

#cd to count directory
cd /scratchb/sblab/dhir01/Projects/Xiaoyun/SLX-21770/aligned/count
mkdir collapsed_count
for file in *tsv
do
sbatch --time 12:00:00 --mem 8G --wrap "alleyoop collapse -o ./collapsed_count -t 2  $file"
done



# https://t-neumann.github.io/slamdunk/docs.html#tcount-file-format -  see section Tcount file format
cd /scratchb/sblab/dhir01/Projects/Xiaoyun/SLX-21770/aligned/count
for file in *_tcount.tsv
do
awk '!seen[$1,$2,$3]++' $file | awk '{print $4"_"$1"_"$2"_"$3"\t"$12"\t"$13"\t"$5}' > ${file%%.tsv}.reduced.tsv
done

