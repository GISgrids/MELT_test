process MELT_INS_MAKEVCF {
  
    tag "MAKE_VCF"
    label 'process_low'

    // ### The template commands for loading containers have been commented out. ###
    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/melt:1.0.3--py36_2':
    //    'biocontainers/melt:1.0.3--py36_2' }"
    //conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container 'bioinfo4cabbage/melt:1.0'

    input:
    path meltgroupanalysis_ch
    path meltgenotype_ch
    each mobileElementIns
    path fasta
    path fai

    output:
    path("*/*/*.vcf")                                  , emit: meltmakevcf_ch
    // path "versions.yml"                 , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    //
    // What are the files required?
    // Step 3 GroupAnalysis output
    // Step 4 Genotyping output
    //

    //
    // This step will create a single VCF file for each ME type (i.e. LINE1, ALU, SVA, etc.) 
    // 

    script:
    def args = task.ext.args ?: ''
    //def prefix = task.ext.prefix ?: "$meta.id"
    
    """
    mkdir -p ${mobileElementIns}_DISCOVERY/FINAL_VCF ${mobileElementIns}_DISCOVERY/GroupAnalysis ${mobileElementIns}_DISCOVERY/Genotype
    mv *${mobileElementIns}.tsv ${mobileElementIns}_DISCOVERY/Genotype
    mv ${mobileElementIns}.* ${mobileElementIns}_DISCOVERY/GroupAnalysis

    java -Xmx6G -jar /opt/MELT.jar MakeVCF \\
        $args \\
        -genotypingdir ${mobileElementIns}_DISCOVERY/Genotype \\
        -h ${fasta} \\
        -t /opt/me_refs/Hg38/${mobileElementIns}_MELT.zip \\
        -w ${mobileElementIns}_DISCOVERY/FINAL_VCF \\
        -p ${mobileElementIns}_DISCOVERY/GroupAnalysis \\
        -o ${mobileElementIns}_DISCOVERY/FINAL_VCF
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

