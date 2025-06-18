process filter_variants {

    container 'community.wave.seqera.io/library/bcftools:1.22--a51ee80717c2467e'

    tag "filter: variants"

    input:
    path vardir
    val num_alleles
    val threads

    script:
    """
    mkdir -p \$(readlink -f ${vardir})
    if [ ! -f \$(readlink -f ${vardir}/filter_vcf__SUCCESS) ]; then
        bcftools view \
            -e "(INFO/AN / $num_alleles) < ${params.sampling_threshold}" \
            ${vardir}/raw_genotype_calls.vcf.gz | \
        bcftools view \
            -e "${params.quality_filter}" | \
        sed -E 's/\\t\\.:/\\t\\.\\/\\.:/g' | \
        bcftools view -Oz -o ${vardir}/filtered_genotype_calls.vcf.gz && \
        bcftools index -t ${vardir}/filtered_genotype_calls.vcf.gz && \
        echo "" > \$(readlink -f $${vardir}/filter_vcf__SUCCESS)
    fi
    """

    output:
    path true, emit: filtered_vcf
}