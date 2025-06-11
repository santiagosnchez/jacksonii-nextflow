nextflow.enable.dsl = 2

include { get_sra_accessions } from './modules/samples.nf'
include { run_fasterq_dump } from './modules/fetch.nf'
include { fetch_reference_genome } from './modules/fetch.nf'
include { run_trimmomatic } from './modules/trim.nf'
include { index_genome_bwa } from './modules/index.nf'
include { run_bwa_mem_paired } from './modules/align.nf'
include { run_bwa_mem_single } from './modules/align.nf'
include { merge_bam_files } from './modules/align.nf'
include { clear_fastq_reads } from './modules/clean.nf'


def input_from_sra = file(params.from_sra) ?: null

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
    // get fastq files from SRA
    reads_ch = get_sra_accessions.out.splitText().map { it.trim() }
    run_fasterq_dump(reads_ch, params.fastq_dir, params.tmp_dir)
    run_trimmomatic(run_fasterq_dump.out, params.fastq_dir, params.threads)
    // get reference genome and index it
    fetch_reference_genome(params.ref_genome_url, params.genome_dir)
    index_genome_bwa(fetch_reference_genome.out.ref_genome)
    
}