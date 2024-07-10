process MELT_DELMERGE {

    // tag "$meta"
    label 'process_low'

    // ### The template commands for loading containers have been commented out. ###
    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/melt:1.0.3--py36_2':
    //    'biocontainers/melt:1.0.3--py36_2' }"
    container 'bioinfo4cabbage/melt:1.0'

    input:
    path tsv
    path fasta
    path fai

    output:
    path("*/*.vcf")  , emit: vcf // 0-base item number (important in the MELT_DELMERGE process)
    // path("LINE1/*.vcf")  , emit: l1_vcf
    // path "versions.yml"                 , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    script:
    // def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${meta}"

    // Set the MELT jar file to the exact file path in my local directory, as accessing the MELT.jar file within the 
    // Docker container did not seem to work. 
    // When upscaling to NF-tower, need to access the MELTv2.2.2 folder via AWS S3 bucket storage.
    
    // ls *.tsv > `pwd`/list_of_outputs.txt
    """
    #!/usr/bin/bash
    
    for name in LINE1 AluY; do
      ls *\${name}.del.tsv > list_of_outputs_\${name}.txt
      mkdir \${name}
      java -Xmx6g -jar /opt/MELT.jar Deletion-Merge \\
        -mergelist `pwd`/list_of_outputs_\${name}.txt \\
        -bed /opt/add_bed_files/Hg38/\${name}.deletion.bed \\
        -h ${fasta} \\
        -o ./\${name}
    done
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
