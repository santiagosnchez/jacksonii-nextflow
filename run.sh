#!/bin/bash

export GID=$(id -g)
export UID=$(id -u)

mkdir -p ./.tmp
mkdir -p ./data

nextflow -C nextflow.config run main.nf \
    --from_sra SraRunTable.csv \
    -resume
    # -with-trace -with-timeline timeline.html -with-report -with-dag dag.svg \
    # -w work --outdir results "$@"
