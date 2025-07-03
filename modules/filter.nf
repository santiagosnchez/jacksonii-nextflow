process filter_variants {

    container 'community.wave.seqera.io/library/bcftools:1.22--a51ee80717c2467e'

    tag "filter_variants"

    input:
    val merge_variants_is_done
    path var_dir

    when:
    merge_variants_is_done == true

    script:
    """
    mkdir -p ${var_dir}
    if [[ ! -f ${var_dir}/filter_variants__SUCCESS ]]; then
        bcftools filter \
            --mode + \
            --soft-filter "F_MISSING_${params.min_fraction_missing}" \
            -e "INFO/F_MISSING > ${params.min_fraction_missing}" \
            ${var_dir}/merged_variants.vcf.gz | \
        bcftools filter \
            --mode + \
            --soft-filter "ALT_IS_REF" \
            -e "ALT='.'" | \
        bcftools filter \
            --mode + \
            --soft-filter "PRIVATE" \
            -e "INFO/AC=1" | \
        bcftools view -Oz -o ${var_dir}/annotated_variants.vcf.gz && \
        bcftools index -t ${var_dir}/annotated_variants.vcf.gz && \
        bcftools view -f PASS -Oz -o ${var_dir}/filtered_variants.vcf.gz \
            ${var_dir}/annotated_variants.vcf.gz && \
        bcftools index -t ${var_dir}/filtered_variants.vcf.gz && \
        echo "" > ${var_dir}/filter_variants__SUCCESS
    fi
    """

    output:
    val true, emit: filtered_vcf
    path "${var_dir}/filtered_variants.vcf.gz", emit: filtered_genotype_calls

}