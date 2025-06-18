process make_windows {

    container 'community.wave.seqera.io/library/bcftools_bedtools_samtools:f1acc4ec7fbdba9e'

    tag "intervals: ${params.call_processes}"

    input:
    path reference_fasta_idx

    script:
    """
    mkdir -p regions
    bedtools makewindows \
        -g ${reference_fasta_idx} \
        -w 100000 | \
    awk '{print \$1":"\$2+1"-"\$3}' > regions.txt && \
    split -l 1 -d regions.txt regions/r_
    """

    output:
    path "regions/*", emit: region

}