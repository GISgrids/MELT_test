process MELT_DELMERGE {

    tag "MELT-Deletion-Merging"
    label 'process_low'

    // ### The template commands for loading containers have been commented out. ###
    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/melt:1.0.3--py36_2':
    //    'biocontainers/melt:1.0.3--py36_2' }"
    container 'bioinfo4cabbage/melt:1.0'

    input:
    path meltdelgeno_ch
    each mobileElementDel
    path fasta
    path fai

    output:
    path("*/*.vcf")  , emit: meltdelmerge_ch
    // path "versions.yml"                 , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    
    //
    // Generation of MELT Deletion's final merged VCF 
    //

    """
    ls *.${mobileElementDel}.del.tsv > list_of_outputs_${mobileElementDel}.txt
    mkdir ${mobileElementDel}_DELETION
    java -Xmx6g -jar /opt/MELT.jar Deletion-Merge \\
      $args \\
      -mergelist list_of_outputs_${mobileElementDel}.txt \\
      -bed /opt/add_bed_files/Hg38/${mobileElementDel}.deletion.bed \\
      -h ${fasta} \\
      -o ${mobileElementDel}_DELETION
    
    mv ./${mobileElementDel}_DELETION/DEL.final_comp.vcf ./${mobileElementDel}_DELETION/MELT_Deletion_${mobileElementDel}_merged.vcf
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
