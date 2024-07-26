process MELT_DELGENO {
  
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
    each mobileElementDel
    path fasta
    path fai

    output:
    path("*/*/*.tsv")    , emit: meltdelgeno_ch  
    path "versions.yml"                 , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    //
    // This step would generate .tsv files for every sample, which would be collectively used for the next step: Deletion-Merge.
    //

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "$meta.id"
    def MELT_VERSION = '2.2.2'
    
    """
    mkdir -p ${mobileElementDel}_DELETION/tsv
    java -Xmx6g -jar /opt/MELT.jar Deletion-Genotype \\
      $args \\
      -bamfile ${input} \\
      -w . \\
      -bed /opt/add_bed_files/Hg38/${mobileElementDel}.deletion.bed \\
      -h ${fasta} 
    
    sampleName=\$(basename ${meta.id}*.del.tsv .del.tsv)
    mv \${sampleName}.del.tsv ${mobileElementDel}_DELETION/tsv/\${sampleName}.${mobileElementDel}.del.tsv


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MELT: ${MELT_VERSION}
    END_VERSIONS
    """

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
