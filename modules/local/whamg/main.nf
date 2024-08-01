process WHAMG_SV {
    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-fb3127231a8f88daa68d5eb0eec49593cd98b440:e6a1c182ebdfe372b5e3cdc05a6cece64cef7274-0':
        'biocontainers/mulled-v2-fb3127231a8f88daa68d5eb0eec49593cd98b440:e6a1c182ebdfe372b5e3cdc05a6cece64cef7274-0' }"

    input:
    tuple val(meta), path(input), path(input_index)
    path fasta
    path fai

    output:
    //tuple val(meta), path("*.vcf")          , emit: whamg_vcf
    tuple val(meta), path("*.vcf.gz")       , emit: whamg_vcfgz
    tuple val(meta), path("*.vcf.gz.tbi")   , emit: whamg_vcfgztbi
    tuple val(meta), path("*.txt")          , emit: graph, optional: true
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    // WHAMG can only take in BAM files; will freeze when CRAM files are input.

    """
    whamg \\
        -x ${task.cpus} \\
        -f ${input} \\
        -a ${fasta} \\
        $args \\
        > WHAMG_${prefix}.vcf

    bgzip WHAMG_${prefix}.vcf --threads ${task.cpus} --stdout > WHAMG_${prefix}.vcf.gz
    tabix WHAMG_${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        whamg: \$(echo \$(whamg 2>&1 | grep Version | sed 's/^Version: v//; s/-.*\$//' ))
        bgzip: \$(echo \$(bgzip --version | grep bgzip | sed 's/bgzip //'))
        tabix: \$(echo \$(tabix --version | grep tabix | sed 's/tabix //'))
    END_VERSIONS
    """

    
    stub: 
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    touch WHAMG_${prefix}.vcf
    touch WHAMG_${prefix}.vcf.gz
    touch WHAMG_${prefix}.vcf.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        whamg: \$(echo \$(whamg 2>&1 | grep Version | sed 's/^Version: v//; s/-.*\$//' ))
        bgzip: \$(echo \$(bgzip --version | grep bgzip | sed 's/bgzip //'))
        tabix: \$(echo \$(tabix --version | grep tabix | sed 's/tabix //'))
    END_VERSIONS
    """

}
