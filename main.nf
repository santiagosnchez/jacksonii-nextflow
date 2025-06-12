nextflow.enable.dsl = 2

include { get_sra_accessions } from './modules/samples.nf'
include { get_populations } from './modules/samples.nf'
include { run_fasterq_dump } from './modules/fetch.nf'
include { fetch_reference_genome } from './modules/fetch.nf'
include { bgzip_reference_genome } from './modules/fetch.nf'
include { run_trimmomatic } from './modules/trim.nf'
include { index_genome_bwa } from './modules/index.nf'
include { index_genome_samtools } from './modules/index.nf'
include { run_bwa_mem_paired } from './modules/align.nf'
include { run_bwa_mem_single } from './modules/align.nf'
include { merge_bam_files } from './modules/align.nf'
include { clear_fastq_reads } from './modules/clean.nf'
include { call_variants } from './modules/call.nf'


def input_from_sra = file(params.from_sra) ?: null
def bam_files = Channel.empty()
def bam_files_str = null

if (!input_from_sra) {
    error "Please provide a CSV file with SRA accessions using the --from_sra parameter."
}
else {
    if (!file(input_from_sra).exists()) {
        error "The specified file does not exist: ${params.from_sra}"
    }
    else {
        if (!file(input_from_sra).isAbsolute()) {
            input_from_sra = file("${workflow.projectDir}/${input_from_sra}")
        }
    }
}

workflow {

    println "Using absolute path for input file: ${input_from_sra}"
    get_sra_accessions(input_from_sra)
    get_populations(input_from_sra, params.samples_dir)
    // get fastq files from SRA
    reads_ch = get_sra_accessions.out.splitText().map { it.trim() }
    run_fasterq_dump(reads_ch, params.fastq_dir, params.tmp_dir)
    run_trimmomatic(run_fasterq_dump.out, params.fastq_dir, params.threads)
    // get reference genome and index it
    fetch_reference_genome(params.ref_genome_url, params.genome_dir)
    bgzip_reference_genome(
        fetch_reference_genome.out.ref_genome,
        fetch_reference_genome.out.ref_genome_gz
    )
    index_genome_bwa(bgzip_reference_genome.out.ref_genome_gz)
    index_genome_samtools(bgzip_reference_genome.out.ref_genome_gz)
    // align reads to the reference genome
    run_bwa_mem_paired(
        run_trimmomatic.out, 
        params.fastq_dir, 
        params.bam_dir, 
        index_genome_bwa.out.indexed_ref_genome, 
        params.threads
    )
    run_bwa_mem_single(
        run_trimmomatic.out, 
        params.fastq_dir, 
        params.bam_dir, 
        index_genome_bwa.out.indexed_ref_genome, 
        params.threads
    )
    // merge BAM files
    merge_bam_files(
        run_bwa_mem_paired.out.align_paired_success && run_bwa_mem_single.out.align_single_success,
        run_bwa_mem_paired.out.sra_accession, 
        params.bam_dir, 
        params.threads
    )
    // clean up FASTQ files
    clear_fastq_reads(
        merge_bam_files.out.merge_success,
        merge_bam_files.out.sra_accession,
        params.fastq_dir, 
    )
    // call variants (this part is commented out in the original code)    
    bam_files = merge_bam_files.out.bam_file
    bam_files_str = bam_files.collect().map { it.join(' ') }
    call_variants(
        bam_files_str, 
        params.var_dir, 
        index_genome_samtools.out.indexed_ref_genome, 
        get_populations.out.populations_file
    )

}