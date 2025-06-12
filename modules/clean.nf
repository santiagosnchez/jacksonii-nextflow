process clear_fastq_reads {

    tag "clear_fastq_reads"

    input:
    val aligned_reads
    val sra_accession
    path fastq_dir

    when:
    aligned_reads == true

    script:
    """
    if [ -f ${fastq_dir}/${sra_accession}_1.trimmed.fastq.gz ]; then
        rm -f ${fastq_dir}/${sra_accession}_*.fastq.gz
    fi
    
    """

}