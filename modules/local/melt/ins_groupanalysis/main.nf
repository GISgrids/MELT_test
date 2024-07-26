process MELT_INS_GROUPANALYSIS {
  
    tag "MELT-Insertion-GroupAnalysis"
    label 'process_low'

    // ### The template commands for loading containers have been commented out. ###
    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/melt:1.0.3--py36_2':
    //    'biocontainers/melt:1.0.3--py36_2' }"
    //conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container 'bioinfo4cabbage/melt:1.0'

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
