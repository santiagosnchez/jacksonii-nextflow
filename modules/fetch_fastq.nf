process run_fasterq_dump {

    container 'community.wave.seqera.io/library/sra-tools:3.2.1--2063130dadd340c5'

    tag "$sra_accession"

    input:
    val sra_accession
    path reads_dir


    output:
    tuple val(sra_accession), 
          path("${reads_dir}/${sra_accession}_1.fastq.gz"), 
          path("${reads_dir}/${sra_accession}_2.fastq.gz")

    script:
    """
    fasterq-dump --split-files ${sra_accession} -O ${output_dir}
    gzip ${output_dir}/${sra_accession}_1.fastq
    gzip ${output_dir}/${sra_accession}_2.fastq
    """
}