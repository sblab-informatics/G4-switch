#!/bin/bash

#Annotation files
#==================

# For 3'UTR annotation, download the gff3 file from gencode (version used: Gencodev37) from https://www.gencodegenes.org/human/release_37.html
grep three_prime_UTR gencode.v37.annotation.gff3 > gencode.v37.3primeUTR.gff3
awk '{ if ($3=="gene") print $0}' gencode.v37.annotation.gff3 > gencode.v37.GeneBody.gff3
awk '{print $1"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' gencode.v37.3primeUTR.gff3 | sed 's/;Parent*.*//g'  | sed 's/ID=UTR3://g' | sed 's/\.[0-9]$//'| awk -v OFS='\t' '{print $1,$2,$3,$7,$4,$5}' > gencode.v37.3primeUTR.bed


#Extract genebody 
awk '{print $1"\t"$4"\t"$5"\t"$6"\t"$8"\t"$7"\t"$9}' gencode.v37.GeneBody.gff3 | sed 's/;gene_type=*.*//g' | sed 's/*;gene_type=//g' | sed 's/\.[0-9].*$//'| sed 's/ID=//g' > gencode.v37.GeneBody.bed


# genes to transcript map
awk '{print $1"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' gencode.v37.3primeUTR.gff3 | gawk -F'gene_id=' '{print $1,$2}'  |  sed 's/;transcript_id*.*//g' | gawk -F';' '{print $1,$2,$3}' | awk '{OFS="\t";print $1,$2,$3,$4,$5,$8,$9}' | sed 's/Parent=//g' >gencode.v37.genes_to_transcript.bed

#extract promoters 
genome=hg38_selected.sorted.genome
awk '{if($6 =="+") {print $1"\t"$2"\t"$2"\t"$4"\t"$5"\t"$6"\t"$7} else if($6=="-") {print $1"\t"$3"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7}}'  gencode.v37.GeneBody.bed | bedtools slop -l 500 -i - -g $genome -s -r 0 > gencode.v37.TSSminus500.bed

genome=hg38_selected.sorted.genome
awk '{if($6 =="+") {print $1"\t"$2"\t"$2+1"\t"$4"\t"$5"\t"$6"\t"$7} else if($6=="-") {print $1"\t"$3-1"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7}}'  gencode.v37.GeneBody.bed > gencode.v37.TSS.bed


