process run_trimmomatic {
    
    container 'community.wave.seqera.io/library/trimmomatic:0.39--a688969e471089d7'
    
    tag "fastq: $sra_accession"
    
    input:
    val sra_accession
    path fastq_dir
    val threads
    
    script:
    """
    if [ ! -f ${fastq_dir}/${sra_accession}__run_trimmomatic__SUCCESS ]; then
        trimmomatic PE -threads $threads \
            ${fastq_dir}/${sra_accession}_1.fastq.gz ${fastq_dir}/${sra_accession}_2.fastq.gz \
            ${fastq_dir}/${sra_accession}_1.trimmed.fastq.gz \
            ${fastq_dir}/${sra_accession}_1.unpaired.fastq.gz \
            ${fastq_dir}/${sra_accession}_2.trimmed.fastq.gz \
            ${fastq_dir}/${sra_accession}_2.unpaired.fastq.gz \
            ILLUMINACLIP:/usr/share/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 \
            LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 && \
        echo "" > ${fastq_dir}/${sra_accession}__run_trimmomatic__SUCCESS
    fi
    """

    output:
    val sra_accession
    
}