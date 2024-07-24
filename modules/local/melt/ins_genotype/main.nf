process MELT_INS_GENOTYPE {
  
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
    path meltgroupanalysis_ch
    each mobileElementIns
    path fasta
    path fai

    output:
    path("*/*/*.tsv")                                  , emit: meltgenotype_ch
    // path "versions.yml"                 , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    //
    // only require the 6 files produced in GroupAnalysis, and the original CRAM/BAM file for each sample.
    //

    //
    // This step will create a .tsv file for each sample, which would be required for merging in Step 5 - MakeVCF 
    // 

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "$meta.id"
    
    """
    mkdir -p ${mobileElementIns}_DISCOVERY/Genotype
    mv ${mobileElementIns}.* ${mobileElementIns}_DISCOVERY
    java -Xmx6G -jar /opt/MELT.jar Genotype \\
        $args \\
        -bamfile ${input} \\
        -t /opt/me_refs/Hg38/${mobileElementIns}_MELT.zip \\
        -h ${fasta} \\
        -p ./${mobileElementIns}_DISCOVERY \\
        -w ./${mobileElementIns}_DISCOVERY/Genotype
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

