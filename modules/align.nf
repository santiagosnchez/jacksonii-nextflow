process run_bwa_mem_paired {

    container 'community.wave.seqera.io/library/bwa-mem2_htslib_samtools:e1f420694f8e42bd'

    tag "align: $sra_accession"

    input:
    val sra_accession
    path fastq_dir
    path bam_dir
    path ref_genome
    val threads

    script:
    """
    mkdir -p \$(readlink -f ${bam_dir})
    if [ ! -f ${bam_dir}/${sra_accession}__run_bwa_mem_paired__SUCCESS ]; then
        ln -s ${params.genome_dir}/${ref_genome}.bwt.2bit.64 . && \
        ln -s ${params.genome_dir}/${ref_genome}.0123 . && \
        ln -s ${params.genome_dir}/${ref_genome}.ann . && \
        ln -s ${params.genome_dir}/${ref_genome}.amb . && \
        ln -s ${params.genome_dir}/${ref_genome}.pac . && \
        bwa-mem2 mem -t $threads ${ref_genome} \
            ${fastq_dir}/${sra_accession}_1.trimmed.fastq.gz \
            ${fastq_dir}/${sra_accession}_2.trimmed.fastq.gz | \
        samtools view -bS - > ${bam_dir}/${sra_accession}_paired.bam && \
        samtools sort -@ $threads -o ${bam_dir}/${sra_accession}_sorted_paired.bam ${bam_dir}/${sra_accession}_paired.bam && \
        echo "" > ${bam_dir}/${sra_accession}__run_bwa_mem_paired__SUCCESS
    fi
    """

    output:
    val true, emit: align_paired_success
    val sra_accession, emit: sra_accession

}

process run_bwa_mem_single {

    container 'community.wave.seqera.io/library/bwa-mem2_htslib_samtools:e1f420694f8e42bd'

    tag "align: $sra_accession"

    input:
    val sra_accession
    path fastq_dir
    path bam_dir
    path ref_genome
    val threads

    script:
    """
    mkdir -p \$(readlink -f ${bam_dir})
    if [ ! -f ${bam_dir}/${sra_accession}__run_bwa_mem_single__SUCCESS ]; then
        ln -s ${params.genome_dir}/${ref_genome}.bwt.2bit.64 . && \
        ln -s ${params.genome_dir}/${ref_genome}.0123 . && \
        ln -s ${params.genome_dir}/${ref_genome}.ann . && \
        ln -s ${params.genome_dir}/${ref_genome}.amb . && \
        ln -s ${params.genome_dir}/${ref_genome}.pac . && \
        bwa-mem2 mem -t $threads ${ref_genome} \
            <(cat ${fastq_dir}/${sra_accession}_1.unpaired.fastq.gz \
            ${fastq_dir}/${sra_accession}_2.unpaired.fastq.gz) | \
        samtools view -bS - > ${bam_dir}/${sra_accession}_unpaired.bam && \
        samtools sort -@ $threads -o ${bam_dir}/${sra_accession}_sorted_unpaired.bam ${bam_dir}/${sra_accession}_unpaired.bam && \
        echo "" > ${bam_dir}/${sra_accession}__run_bwa_mem_single__SUCCESS
    fi
    """

    output:
    val true, emit: align_single_success
    val sra_accession, emit: sra_accession
    
}

process merge_bam_files {

    container 'community.wave.seqera.io/library/bwa-mem2_htslib_samtools:e1f420694f8e42bd'

    tag "align: $sra_accession"

    input:
    val align_success
    val sra_accession
    path bam_dir
    val threads

    when:
    align_success == true

    script:
    """
    if [[ ! -f ${params.bam_dir}/${sra_accession}__merge_bam_files__SUCCESS ]]; then
        samtools merge -f -@ $threads ${bam_dir}/${sra_accession}_merged.bam \
            ${bam_dir}/${sra_accession}_sorted_paired.bam \
            ${bam_dir}/${sra_accession}_sorted_unpaired.bam && \
        samtools addreplacerg \
            -r "ID:${sra_accession}" \
            -r "SM:${sra_accession}" \
            -o ${bam_dir}/${sra_accession}_merged.rg.bam \
            ${bam_dir}/${sra_accession}_merged.bam && \
        mv ${bam_dir}/${sra_accession}_merged.rg.bam ${bam_dir}/${sra_accession}_merged.bam && \
        samtools index ${bam_dir}/${sra_accession}_merged.bam && \
        rm -f ${bam_dir}/${sra_accession}_sorted_paired.bam && \
        rm -f ${bam_dir}/${sra_accession}_sorted_unpaired.bam && \
        rm -f ${bam_dir}/${sra_accession}_paired.bam && \
        rm -f ${bam_dir}/${sra_accession}_unpaired.bam && \
        echo "" > ${params.bam_dir}/${sra_accession}__merge_bam_files__SUCCESS
    fi
    """

    output:
    val true, emit: merge_success
    val sra_accession, emit: sra_accession
    path "${bam_dir}/${sra_accession}_merged.bam", emit: bam_file

}