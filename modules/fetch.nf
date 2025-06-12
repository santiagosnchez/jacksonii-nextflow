process run_fasterq_dump {

    container 'community.wave.seqera.io/library/sra-tools:3.2.1--2063130dadd340c5'

    tag "fetch: $sra_accession"

    input:
    val sra_accession
    path fastq_dir
    path tmp_dir

    script:
    """
    mkdir -p \$(readlink -f ${fastq_dir})
    MANIFEST_FILE=\$(readlink -f ${fastq_dir}/${sra_accession}__run_fasterq_dump__SUCCESS)
    if [ ! -f \$MANIFEST_FILE ]; then
        fasterq-dump \
            --force \
            --split-files ${sra_accession} \
            --temp ${tmp_dir} \
            -O ${fastq_dir} && \
        gzip -f ${fastq_dir}/${sra_accession}_1.fastq && \
        gzip -f ${fastq_dir}/${sra_accession}_2.fastq && \
        echo "" > \$MANIFEST_FILE
    fi
    """

    output:
    val sra_accession

}

process fetch_reference_genome {

    container 'community.wave.seqera.io/library/bash_wget:27285e53874b2d1f'

    tag "fetch: reference genome"

    input:
    val ref_genome_url
    path genome_dir

    script:
    """
    mkdir -p \$(readlink -f ${genome_dir})
    REF_GENOME_FILE=\$(readlink -f ${genome_dir}/reference.fasta)
    if [ ! -f \$REF_GENOME_FILE ]; then
        wget -O \$REF_GENOME_FILE.gz "${ref_genome_url}" && \
        gzip -dc \$REF_GENOME_FILE.gz > \$REF_GENOME_FILE && \
        echo "Reference genome downloaded to \$REF_GENOME_FILE"
    fi
    """

    output:
    val true, emit: ref_genome_downloaded
    path "${genome_dir}/reference.fasta", emit: ref_genome
    path "${genome_dir}/reference.fasta.gz", emit: ref_genome_gz

}