process clear_fastq_reads {

    tag "clear_fastq_reads"

    input:
    path sra_accession
    path 

    script:
    """
    rm -f ${fastq_dir}/${sra_accession}_*.fastq.gz
    """

    output:
    val true, emit: cleared

}