process SAMPLESHEET_CHECK {
    
    tag "$inputsheet"
    label 'process_low'

    // todo: do we need a docker container containing python3 to be able to run the python script if we run this pipeline on NF-Tower?
    // if not, can ignore this line.
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'quay.io/biocontainers/python:3.9--1' }"

    input:
    path inputsheet

    output:
    path '*valid.csv'       , emit: csv
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in nf-core/rnaseq/bin/
    """
    check_samplesheet.py $inputsheet samplesheet.valid.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version | sed 's/Python //g')
    END_VERSIONS
    """
}
