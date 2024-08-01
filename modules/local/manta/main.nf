process MANTA_SV {
    tag "$meta.id"
    label 'process_low'
    
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/manta:1.6.0--h9ee0642_1' :
        'biocontainers/manta:1.6.0--h9ee0642_1' }"

    input:
    tuple val(meta), path(input), path(input_index)
    path fasta
    path fai

    output:
    tuple val(meta), path("*/*candidate_small_indels.vcf.gz")           , emit: manta_candidate_small_indels_vcf
    tuple val(meta), path("*/*candidate_small_indels.vcf.gz.tbi")       , emit: manta_candidate_small_indels_vcf_tbi
    tuple val(meta), path("*/*candidate_sv.vcf.gz")                     , emit: manta_candidate_sv_vcf
    tuple val(meta), path("*/*candidate_sv.vcf.gz.tbi")                 , emit: manta_candidate_sv_vcf_tbi
    tuple val(meta), path("*/*diploid_sv.vcf.gz")                       , emit: manta_diploid_sv_vcf
    tuple val(meta), path("*/*diploid_sv.vcf.gz.tbi")                   , emit: manta_diploid_sv_vcf_tbi
    path "versions.yml"                                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''

    """
    mkdir manta
    /usr/local/share/manta-1.6.0-1/bin/configManta.py \\
        --bam ${input} \\
        --referenceFasta GRCh38_broad.fasta \\
        --runDir manta \\
        $args
    
    python manta/runWorkflow.py -j $task.cpus

    mkdir candidate_small_indels candidate_sv diploid_sv
    mv manta/results/variants/candidateSmallIndels.vcf.gz \\
        candidate_small_indels/MANTA_${prefix}.candidate_small_indels.vcf.gz
    mv manta/results/variants/candidateSmallIndels.vcf.gz.tbi \\
        candidate_small_indels/MANTA_${prefix}.candidate_small_indels.vcf.gz.tbi
    mv manta/results/variants/candidateSV.vcf.gz \\
        candidate_sv/MANTA_${prefix}.candidate_sv.vcf.gz
    mv manta/results/variants/candidateSV.vcf.gz.tbi \\
        candidate_sv/MANTA_${prefix}.candidate_sv.vcf.gz.tbi
    mv manta/results/variants/diploidSV.vcf.gz \\
        diploid_sv/MANTA_${prefix}.diploid_sv.vcf.gz
    mv manta/results/variants/diploidSV.vcf.gz.tbi \\
        diploid_sv/MANTA_${prefix}.diploid_sv.vcf.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        manta: \$(echo \$(/usr/local/share/manta-1.6.0-1/bin/configManta.py 2>&1 | grep 'Version' | sed 's/^Version: //'))
    END_VERSIONS
    """

    stub: 
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    
    """
    mkdir candidate_small_indels candidate_sv diploid_sv
    
    touch candidate_small_indels/MANTA_${prefix}.candidate_small_indels.vcf.gz
    touch candidate_small_indels/MANTA_${prefix}.candidate_small_indels.vcf.gz.tbi
    touch candidate_sv/MANTA_${prefix}.candidate_sv.vcf.gz
    touch candidate_sv/MANTA_${prefix}.candidate_sv.vcf.gz.tbi
    touch diploid_sv/MANTA_${prefix}.diploid_sv.vcf.gz
    touch diploid_sv/MANTA_${prefix}.diploid_sv.vcf.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        manta: \$(echo \$(/usr/local/share/manta-1.6.0-1/bin/configManta.py 2>&1 | grep 'Version' | sed 's/^Version: //'))
    END_VERSIONS
    """

}
