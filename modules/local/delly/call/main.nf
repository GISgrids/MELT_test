process DELLY_CALL {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/delly:1.2.6--hb7e2ac5_1' :
        'biocontainers/delly:1.2.6--hb7e2ac5_1' }"

    input:
    tuple val(meta), path(input), path(input_index)
    path fasta
    path fai

    output:
    tuple val(meta), path("*.{bcf,vcf.gz}")             , emit: delly_bcf_vcfgz
    tuple val(meta), path("*.{csi,vcf.gz.tbi}")         , emit: delly_csi_vcfgztbi
    path "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def suffix = task.ext.suffix ?: "vcf"

    //def exclude = exclude_bed ? "--exclude ${exclude_bed}" : ""
    //def genotype = vcf ? "--vcffile ${vcf}" : ""

    def bcf_output = suffix == "bcf" ? "--outfile ${prefix}.bcf" : ""
    def vcf_output = suffix == "vcf" ? "| bgzip ${args2} --threads ${task.cpus} --stdout > DELLY_${prefix}.vcf.gz && tabix DELLY_${prefix}.vcf.gz" : ""

    """
    delly \\
        call \\
        ${args} \\
        ${bcf_output} \\
        --genome ${fasta} \\
        ${input} \\
        ${vcf_output}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        delly: \$( echo \$(delly --version 2>&1) | sed 's/^.*Delly version: v//; s/ using.*\$//')
    END_VERSIONS
    """


    stub:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch DELLY_${prefix}.vcf
    touch DELLY_${prefix}.vcf.gz
    touch DELLY_${prefix}.vcf.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        delly: \$( echo \$(delly --version 2>&1) | sed 's/^.*Delly version: v//; s/ using.*\$//')
    END_VERSIONS
    """
}
