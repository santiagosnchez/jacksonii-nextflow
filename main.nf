nextflow.enable.dsl = 2

include { run_fasterq_dump } from './modules/fetch_fastq.nf'

workflow {
    
    sra_accession = 'SRR30172790'

    run_fasterq_dump(sra_accession, params.reads_dir)
}