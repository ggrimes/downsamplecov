# Downsample bam file and then generate bigwig

Downsample bam file and generate coverage


# Steps

* Downsample bam file using samtools 
* Generate bigwig file using deeptools

# Input

sample spreadsheet 2 columns , bam file and scalefactor


# Output


samtools view -s $FRAC 

 bigwig file
 
function from https://bioinformatics.stackexchange.com/questions/402/how-can-i-downsample-a-bam-file-while-keeping-both-reads-in-pairs/5648
 ~~~
function SubSample {

## Calculate the sampling factor based on the intended number of reads:
FACTOR=$(samtools idxstats $1 | cut -f3 | awk -v COUNT=$2 'BEGIN {total=0} {total += $1} END {print COUNT/total}')

if [[ $FACTOR > 1 ]]
  then 
  echo '[ERROR]: Requested number of reads exceeds total read count in' $1 '-- exiting' && exit 1
fi

sambamba view -s $FACTOR -f bam -l 5 $1

}

## Usage example, selecting 100.000 reads:
SubSample ${bam} 100000 > subsampled.bam

bamCoverage --bam subsampled.bam -o a.SeqDepthNorm.bw --binSize 10
~~~
