process MELT_INS_INDIVANALYSIS {
  
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
    tuple val(meta), path(meltpreprocess_ch)
    each mobileElementIns
    path fasta
    path fai

    output:
    path("*/*/*.bam*")                                  , emit: meltindivanalysis_bam_ch
    path("*/*/*.bed")                                   , emit: meltindivanalysis_bed_ch
    // path "versions.yml"                 , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    //
    // This step will create 6 (not all the time) files - 
    // 1. ME_name.aligned.final.sorted.bam
    // 2. ME_name.aligned.final.sorted.bam.bai
    // 3. ME_name.aligned.pulled.sorted.bam
    // 4. ME_name.aligned.pulled.sorted.bam.bai
    // 5. ME_name.hum_breaks.sorted.bam
    // 6. ME_name.hum_breaks.sorted.bam.bai
    // If files 5 and 6 (.hum*) are not present, it means that MELT failed to detect any of that type of ME in the sample's genome specified.
    //

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "$meta.id"
    
    """
    mkdir -p ${mobileElementIns}_DISCOVERY/IndivAnalysis
    java -Xmx6G -jar /opt/MELT.jar IndivAnalysis \\
        $args \\
        -bamfile $meta.id*.bam \\
        -w ./${mobileElementIns}_DISCOVERY/IndivAnalysis \\
        -t /opt/me_refs/Hg38/${mobileElementIns}_MELT.zip \\
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
