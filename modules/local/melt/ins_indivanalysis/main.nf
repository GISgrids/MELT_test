process MELT_INS_INDIVANALYSIS {
  
    tag "$meta.id"
    label 'process_low'

    // ### The template commands for loading containers have been commented out. ###
    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/melt:1.0.3--py36_2':
    //    'biocontainers/melt:1.0.3--py36_2' }"
    //conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container 'docker.io/bioinfo4cabbage/melt:1.0'

    input:
    tuple val(meta), path(meltpreprocess_ch)
    each mobileElementIns
    path fasta
    path fai

    output:
    path("*/*/*.bam*")                  , emit: meltindivanalysis_bam_ch
    path("*/*/*.bed")                   , emit: meltindivanalysis_bed_ch
    path "versions.yml"                 , emit: versions

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
    // If files 5 and 6 (.hum*) are not present, it means that MELT failed to detect any of that type of ME in the sample genome specified.
    //
    // A .tmp.bed file would also be created for each sample, which is REQUIRED for the next step, GroupAnalysis
    //

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "$meta.id"
    def MELT_VERSION = '2.2.2'
    
    """
    mkdir -p ${mobileElementIns}_DISCOVERY/IndivAnalysis
    java -Xmx6G -jar /opt/MELT.jar IndivAnalysis \\
        $args \\
        -bamfile `ls $meta.id*.cram* $meta.id*.bam*` \\
        -w ./${mobileElementIns}_DISCOVERY/IndivAnalysis \\
        -t /opt/me_refs/Hg38/${mobileElementIns}_MELT.zip \\
        -h ${fasta}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MELT: ${MELT_VERSION}
    END_VERSIONS
    """


    stub: 
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "$meta.id"
    def MELT_VERSION = '2.2.2'
    
    """
    mkdir -p ${mobileElementIns}_DISCOVERY/IndivAnalysis

    touch ${mobileElementIns}_DISCOVERY/IndivAnalysis/${prefix}.${mobileElementIns}.aligned.final.sorted.bam
    touch ${mobileElementIns}_DISCOVERY/IndivAnalysis/${prefix}.${mobileElementIns}.aligned.final.sorted.bam.bai
    touch ${mobileElementIns}_DISCOVERY/IndivAnalysis/${prefix}.${mobileElementIns}.aligned.pulled.sorted.bam
    touch ${mobileElementIns}_DISCOVERY/IndivAnalysis/${prefix}.${mobileElementIns}.aligned.pulled.sorted.bam.bai
    touch ${mobileElementIns}_DISCOVERY/IndivAnalysis/${prefix}.${mobileElementIns}.hum_breaks.sorted.bam
    touch ${mobileElementIns}_DISCOVERY/IndivAnalysis/${prefix}.${mobileElementIns}.hum_breaks.sorted.bam.bai
    touch ${mobileElementIns}_DISCOVERY/IndivAnalysis/${prefix}.${mobileElementIns}.tmp.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MELT: ${MELT_VERSION}
    END_VERSIONS
    """
}
