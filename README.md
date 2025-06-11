# *Amanita jacksonii* - NextFlow Genomics Pipeline

This is a **NextFlow** that will fully process a set of samples hosted on NCBI - SRA, piping them through

 - download,
 - trimming,
 - alignment, and
 - variant-calling

## Expected CSV input

The pipeline expects a CSV table as input, specifically the `SraRunTable.csv` from NCBI-SRA.

## Docker

Currently, the pipeline relies on `docker` to access containerized genomics packages for running specific modules.

It is expected that Docker desktop is installed previous to running the NextFlow pipeline. If running using MacOS, 
installing `docker` CLI using `brew` will also be required.

## Run the pipeline locally

The pipeline can be run simply by invoking the `run.sh` command (which expect the CSV samples table as input)

```
bash run.sh
```

## `data` output directory configuration

The pipeline will output to `data` directory, which is ignored by `git`.

```
data
  |--- samples
  |       |------ SraRunTable.csv
  |
  |--- fastq
  |      |------ SRRXXXX_1.fastq.gz
  |      |------ SRRXXXX_2.fastq.gz
  |
  |--- bam
  |     |-------- SRRXXXX_merged.bam
  |     |-------- SRRXXXX_merged.bam.bai
  |
  |--- genome
          |------ ref_genome.fasta.gz
          |------ ref_genome.fasta.gz.*
```