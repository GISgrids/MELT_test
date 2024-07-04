process MELT_DELGENO {
    // tag "$meta"
    label 'process_low'

    // ### The template commands for loading containers have been commented out. ###
    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/melt:1.0.3--py36_2':
    //    'biocontainers/melt:1.0.3--py36_2' }"
    container 'bioinfo4cabbage/melt:1.0'

    input:
    tuple val(meta), path(input), path(input_index)
    path fasta
    path fai

    output:
    tuple val(meta), path("*.del.tsv")  , emit: tsv
    // path "versions.yml"                 , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    script:
    // def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${meta}"

    // Set the MELT jar file to the exact file path in my local directory, as accessing the MELT.jar file within the 
    // Docker container did not seem to work. 
    // When upscaling to NF-tower, need to access the MELTv2.2.2 folder via AWS S3 bucket storage.
    
    """
    java -Xmx6g -jar /opt/MELT.jar Deletion-Genotype \\
      -bamfile ${input} \\
      -w . \\
      -bed /opt/add_bed_files/Hg38/AluY.deletion.bed \\
      -h ${fasta}
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
