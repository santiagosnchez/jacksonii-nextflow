process run_trimmomatic {
    
    container 'community.wave.seqera.io/library/trimmomatic:0.39--3e9f341707d971dc'
    
    tag "reads: $sra_accession"
    
    input:
    val sra_accession
    path reads_dir
    val threads
    
    script:
    """
    if [ ! -f ${reads_dir}/${sra_accession}__run_trimmomatic__SUCCESS ]; then
        trimmomatic PE -threads $threads \
            ${reads_dir}/${sra_accession}_1.fastq.gz ${reads_dir}/${sra_accession}_2.fastq.gz \
            ${reads_dir}/${sra_accession}_1.trimmed.fastq.gz \
            ${reads_dir}/${sra_accession}_1.unpaired.fastq.gz \
            ${reads_dir}/${sra_accession}_2.trimmed.fastq.gz \
            ${reads_dir}/${sra_accession}_2.unpaired.fastq.gz \
            ILLUMINACLIP:/usr/share/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 \
            LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 && \
        echo "" > ${reads_dir}/${sra_accession}__run_trimmomatic__SUCCESS
    fi
    """

    output:
    val sra_accession
    
}