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
    if [ ! -f "${reads_dir}/${sra_accession}_1.fastq.gz" ] || [ ! -f "${reads_dir}/${sra_accession}_2.fastq.gz" ]; then
        mkdir -p \$(readlink -f "${reads_dir}")
        fasterq-dump --split-files "${sra_accession}" -O "${reads_dir}" && \
        gzip -f "${reads_dir}/${sra_accession}_1.fastq" && \
        gzip -f "${reads_dir}/${sra_accession}_2.fastq"
    fi
    """
}