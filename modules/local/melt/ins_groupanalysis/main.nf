process MELT_INS_GROUPANALYSIS {
  
    tag "MELT-Insertion-GroupAnalysis"
    label 'process_low'

    // ### The template commands for loading containers have been commented out. ###
    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/melt:1.0.3--py36_2':
    //    'biocontainers/melt:1.0.3--py36_2' }"
    //conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container 'docker.io/bioinfo4cabbage/melt:1.0'

    input:
    path meltindivanalysis_bam_ch
    path meltindivanalysis_bed_ch
    each mobileElementIns
    path fasta
    path fai

    output:
    path("*/*/${mobileElementIns}*")    , emit: meltgroupanalysis_ch  
    path "versions.yml"                 , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    //
    // All the 6 files + the .tmp.bed file generated from the IndivAnalysis step (listed in that module's main.nf) are required for MELT to
    // perform GroupAnalysis, if not it will exit with an error code, causing Nextflow to exit as well.
    //

    //
    // This step will create 6 (not all the time) files - 
    // 1. ME_name.pre_geno.tsv
    // 2. ME_name.merged.hum_breaks.sorted.bam
    // 3. ME_name.merged.hum_breaks.sorted.bam.bai
    // 4. ME_name.master.bed
    // 5. ME_name.hum.list
    // 6. ME_name.bed.list
    // Only these files would be required for the next step, step 4 - Genotyping.
    //

    script:
    def args = task.ext.args ?: ''
    def MELT_VERSION = '2.2.2'
    
    """
    mkdir -p ${mobileElementIns}_DISCOVERY/GroupAnalysis
    mv *.${mobileElementIns}.* ${mobileElementIns}_DISCOVERY
    java -Xmx6G -jar /opt/MELT.jar GroupAnalysis \\
        $args \\
        -discoverydir ${mobileElementIns}_DISCOVERY \\
        -w ${mobileElementIns}_DISCOVERY/GroupAnalysis \\
        -t /opt/me_refs/Hg38/${mobileElementIns}_MELT.zip \\
        -h ${fasta} \\
        -n /opt/add_bed_files/Hg38/Hg38.genes.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MELT: ${MELT_VERSION}
    END_VERSIONS
    """


    stub: 
    def args = task.ext.args ?: ''
    def MELT_VERSION = '2.2.2'
    
    """
    mkdir -p ${mobileElementIns}_DISCOVERY/GroupAnalysis

    touch ${mobileElementIns}_DISCOVERY/GroupAnalysis/${mobileElementIns}.bed.list
    touch ${mobileElementIns}_DISCOVERY/GroupAnalysis/${mobileElementIns}.hum.list
    touch ${mobileElementIns}_DISCOVERY/GroupAnalysis/${mobileElementIns}.master.bed
    touch ${mobileElementIns}_DISCOVERY/GroupAnalysis/${mobileElementIns}.merged.hum_breaks.sorted.bam
    touch ${mobileElementIns}_DISCOVERY/GroupAnalysis/${mobileElementIns}.merged.hum_breaks.sorted.bam.bai
    touch ${mobileElementIns}_DISCOVERY/GroupAnalysis/${mobileElementIns}.pre_geno.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MELT: ${MELT_VERSION}
    END_VERSIONS
    """
}
