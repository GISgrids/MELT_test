process WHAMG_SV {
    tag "$meta.id"
    label 'process_low'

    container 'bioinfo4cabbage/whamg:1.0'

    input:
    tuple val(meta), path(input), path(input_index)
    path fasta
    path fai

    output:
    //tuple val(meta), path("*.vcf")          , emit: whamg_vcf
    tuple val(meta), path("*.vcf.gz")       , emit: whamg_vcfgz
    tuple val(meta), path("*.vcf.gz.tbi")   , emit: whamg_vcfgztbi
    tuple val(meta), path("*.txt")          , emit: graph, optional: true
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    // WHAMG can only take in BAM files; will freeze when CRAM files are input.

    """
    whamg \\
        -x ${task.cpus} \\
        -f ${input} \\
        -a ${fasta} \\
        $args \\
        > WHAMG_${prefix}.vcf

    bcftools view WHAMG_${prefix}.vcf -O z \\
        -o WHAMG_${prefix}.vcf.gz
    bcftools index --tbi WHAMG_${prefix}.vcf.gz


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        whamg: \$(echo \$(whamg 2>&1 | grep Version | sed 's/^Version: v//; s/-.*\$//' ))
        bcftools: \$(echo \$(bcftools 2>&1 | grep Version | sed 's/^Version: //'))
    END_VERSIONS
    """

    // | bgzip ${args2} --threads ${task.cpus} --stdout > ${prefix}.vcf.gz

    // tabix ${args3} ${prefix}.vcf.gz

}
