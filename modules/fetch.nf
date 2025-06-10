process run_fasterq_dump {

    container 'community.wave.seqera.io/library/sra-tools:3.2.1--2063130dadd340c5'

    tag "reads: $sra_accession"

    input:
    val sra_accession
    path reads_dir
    path tmp_dir

    script:
    """
    mkdir -p \$(readlink -f ${reads_dir})
    MANIFEST_FILE=\$(readlink -f ${reads_dir}/${sra_accession}__run_fasterq_dump__SUCCESS)
    if [ ! -f \$MANIFEST_FILE ]; then
        fasterq-dump \
            --force \
            --split-files ${sra_accession} \
            --temp ${tmp_dir} \
            -O ${reads_dir} && \
        gzip -f ${reads_dir}/${sra_accession}_1.fastq && \
        gzip -f ${reads_dir}/${sra_accession}_2.fastq && \
        echo "" > \$MANIFEST_FILE
    fi
    """

    output:
    val sra_accession

}