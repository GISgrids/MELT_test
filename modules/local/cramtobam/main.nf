process CRAMTOBAM {
    tag "$meta.id"
    label 'process_low'

    //container 'shuangbroad/whamg:clean'
    container 'bioinfo4cabbage/melt:1.0'

    input:
    tuple val(meta), path(input), path(input_index)
    path fasta
    path fai

    output:
    tuple val(meta), path("*.bam",includeInputs:true), path("*.bai",includeInputs:true)       
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    if ls ${prefix}*.cram 1> /dev/null 2>&1 && ls ${prefix}*.crai 1> /dev/null 2>&1; then
        sampleName=\$(basename ${meta.id}*.cram .cram)
        samtools view -b -h -T GRCh38_broad.fasta -o \${sampleName}.bam \${sampleName}.cram
        samtools index \${sampleName}.bam
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

}
