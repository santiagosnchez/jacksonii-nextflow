process call_variants {

    container 'community.wave.seqera.io/library/bcftools_freebayes:48cc2ff4d068b740'

    tag "call_variants: $sra_accession"

    memory '2 GB'

    input:
    val sra_accession
    path bam_dir
    path var_dir
    path ref_genome

    script:
    """
    mkdir -p ${params.var_dir}
    ln -s "${params.genome_dir}/${ref_genome}.fai" .
    bam_file="bam/${sra_accession}_merged.bam"
    if [[ ! -f ${params.var_dir}/${sra_accession}__raw_genotype_calls__SUCCESS ]]; then
        freebayes \
            -f ${ref_genome} \
            --gvcf \
            --min-alternate-count ${params.min_alt_count} \
            --use-best-n-alleles ${params.use_best_n_alleles} \
            --haplotype-length ${params.haplotype_length} \
            --limit-coverage ${params.limit_coverage} \
            --standard-filters \
            \$bam_file | \
        bcftools sort -Oz -o ${params.var_dir}/${sra_accession}_raw_genotype_calls_sorted.gvcf.gz && \
        bcftools index -t ${params.var_dir}/${sra_accession}_raw_genotype_calls_sorted.gvcf.gz && \
        cp ${params.genome_dir}/${ref_genome}.fai ${params.var_dir}/ && \
        echo "" > ${params.var_dir}/${sra_accession}__raw_genotype_calls__SUCCESS
    fi
    """

    output:
    val true, emit: call_variants_success
    path "${var_dir}/${sra_accession}_raw_genotype_calls_sorted.gvcf.gz", emit: raw_genotype_calls
    path "${var_dir}/${sra_accession}_raw_genotype_calls_sorted.gvcf.gz.tbi", emit: raw_genotype_calls_tbi

}


process merge_variants {

    container 'community.wave.seqera.io/library/bcftools_freebayes:48cc2ff4d068b740'

    tag "merge_variants"

    input:
    val raw_genotype_calls_ch
    path var_dir
    path genome_dir

    script:
    """
    mkdir -p ${params.var_dir}
    if [[ ! -f ${params.var_dir}/merge_variants__SUCCESS ]]; then
        bcftools merge \
            -m all \
            -0 \
            --gvcf ${genome_dir}/reference.fasta \
            ${var_dir}/*gvcf.gz | \
        bcftools view \
            -e 'ALT=\"<*>\" && N_ALT=1' --trim-alt | \
        bcftools +setGT -- -t q -n . -i 'FMT/DP=\".\"' | \
        bcftools +setGT -- -t q -n . -i 'FMT/DP<${params.min_dp}' | \
        bcftools annotate --remove INFO | \
        bcftools +fill-tags -- -t all | \
        bcftools view -Oz -o ${var_dir}/merged_variants.vcf.gz && \
        bcftools index -t ${var_dir}/merged_variants.vcf.gz && \
        echo \"\" > ${params.var_dir}/merge_variants__SUCCESS
    fi
    """

    output:
    val true, emit: merge_variants_success
    path "${var_dir}/merged_variants.vcf.gz", emit: merged_variants

}
