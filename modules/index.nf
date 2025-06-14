process index_genome_bwa {

    container 'community.wave.seqera.io/library/bwa-mem2_htslib_samtools:e1f420694f8e42bd'

    tag "index: $ref_genome"

    input:
    path ref_genome

    script:
    """
    if [ ! -f \$(readlink -f ${ref_genome}).bwt.2bit.64 ]; then
        bwa-mem2 index ${ref_genome} && \
        mv reference.fasta.gz.* ${params.genome_dir}/
    fi
    """

    output:
    val true, emit: index_success
    path ref_genome, emit: indexed_ref_genome

}

process index_genome_samtools {

    container 'community.wave.seqera.io/library/bwa-mem2_htslib_samtools:e1f420694f8e42bd'

    tag "index: $ref_genome"

    input:
    path ref_genome
    path ref_genome_gz

    script:
    """
    if [ ! -f \$(readlink -f ${ref_genome}).fai ]; then
        samtools faidx ${ref_genome} && \
        mv reference.fasta.fai ${params.genome_dir}/
    elif [ ! -f \$(readlink -f ${ref_genome_gz}).fai ]; then
        samtools faidx ${ref_genome_gz} && \
        mv reference.fasta.gz.fai ${params.genome_dir}/
    fi
    """

    output:
    val true, emit: index_success
    path "${ref_genome}", emit: indexed_ref_genome
    path "${ref_genome_gz}", emit: indexed_ref_genome_gz

}