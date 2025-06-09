nextflow.enable.dsl = 2

include { run_fasterq_dump } from './modules/fetch_fastq.nf'
include { get_sra_accessions } from './modules/samples.nf'

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
    reads_ch = get_sra_accessions.out.splitText().map { it.trim() }
    run_fasterq_dump(reads_ch, params.reads_dir, params.tmp_dir)
    
}