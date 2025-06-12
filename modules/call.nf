process call_variants {

    container 'community.wave.seqera.io/library/bcftools_freebayes:48cc2ff4d068b740'

    tag "call_variants"

    input:
    val bam_files
    path var_dir
    path ref_genome
    path populations_file

    script:
    """
    mkdir -p \$(readlink -f ${var_dir})
    ln -s "${params.genome_dir}/${ref_genome}.fai" .
    if [[ ! -f ${var_dir}/call_variants__SUCCESS ]]; then
        freebayes \
            -f ${ref_genome} \
            --populations ${populations_file} \
            --theta 0.005 \
            --min-alternate-count 5 \
            --haplotype-length 0 \
            --limit-coverage 100 \
            --use-reference-allele \
            --standard-filters \
            $bam_files | \
        bcftools view -Oz -o ${var_dir}/raw_genotype_calls.vcf.gz && \
        bcftools index -t ${var_dir}/raw_genotype_calls.vcf.gz && \
        echo "" > ${var_dir}/call_variants__SUCCESS
    fi
    """

    output:
    val true, emit: call_variants_success
    path "${var_dir}/raw_genotype_calls.vcf.gz", emit: raw_vcf
    path "${var_dir}/raw_genotype_calls.vcf.gz.tbi", emit: raw_vcf_index

}
