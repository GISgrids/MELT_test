process MELT_INS_PREPROCESS {
  
    tag "$meta.id"
    label 'process_low'

    // ### The template commands for loading containers have been commented out. ###
    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/melt:1.0.3--py36_2':
    //    'biocontainers/melt:1.0.3--py36_2' }"
    //conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container 'bioinfo4cabbage/melt:1.0'

    input:
    tuple val(meta), path(input), path(input_index)
    path fasta
    path fai

    output:
    tuple val(meta), path("MELT_INS_Preprocess/*.bam*"),    emit: meltpreprocess_ch
    // path "versions.yml"                 , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    //
    // This step will create 3 files - bam.disc, bam.disc.bai, and .bam.fg in the same directory where the .bam files originally were.
    //

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "$meta.id"
    
    """
    mkdir MELT_INS_Preprocess
    java -Xmx6G -jar /opt/MELT.jar Preprocess \\
        $args \\
        -bamfile ${input} \\
        -h ${fasta}
    mv *.bam* MELT_INS_Preprocess
    """

    // cat <<-END_VERSIONS > versions.yml
    // "${task.process}":
    //    melt: \$(samtools --version |& sed '1!d ; s/samtools //')
    // END_VERSIONS
    // """

    // stub: ####
    // def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    
    // """ ####
    // touch ${prefix}.bam

    // cat <<-END_VERSIONS > versions.yml
    // "${task.process}":
    //     melt: \$(samtools --version |& sed '1!d ; s/samtools //')
    // END_VERSIONS
    // """
}
