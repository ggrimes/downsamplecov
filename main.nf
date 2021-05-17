params.bam = 'alignment/*.{bam,bai}'
params.reads=10000000
params.binsize=10

Channel
    .fromFilePairs(params.bam ) { file -> file.name.replaceAll(/.bam|.bai$/,'') }
    .set { samples_ch }

process bigwig {
  publishDir "results", mode:"copy"
  echo true
  
  input:
  set sampleId, file(bam) from samples_ch

  output:
  path "*.bw" into bw_out

  script:
  """
  function SubSample {
  samtools index ${sampleId}.bam
  ## Calculate the sampling factor based on the intended number of reads:
  
  FACTOR=\$(samtools idxstats ${sampleId}.bam | cut -f3 | awk -v COUNT=\$2 'BEGIN {total=0} {total += \$1} END {print COUNT/total}')

  if [[ \$FACTOR > 1 ]]
    then 
    echo '[ERROR]: Requested number of reads exceeds total read count in ${sampleId}.bam -- exiting' && exit 1
  fi

  sambamba view -s \$FACTOR -f bam -l 5 ${sampleId}.bam

 }

 ## Usage example, selecting 100.000 reads:
 SubSample ${sampleId}.bam 100000 > subsampled.${sampleId}.bam
 samtools index subsampled.${sampleId}.bam
 bamCoverage --bam subsampled.${sampleId}.bam -o ${sampleId}.bw --binSize ${params.binsize}
 """


}
