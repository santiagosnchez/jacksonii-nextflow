#!/bin/bash

nextflow -C nextflow.config run main.nf \
    --from_sra data/samples/test_SraRunTable.csv \
    -resume
    # -with-trace -with-timeline timeline.html -with-report -with-dag dag.svg \
    # -w work --outdir results "$@"