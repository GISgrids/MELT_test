process SCRAMBLE_CLUSTERANALYSIS {
    tag "$meta.id"
    label 'process_low'
    debug true
    
    //conda "${moduleDir}/environment.yml"
    //container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/scramble:1.0.1--h779adbc_1':
    //    'biocontainers/scramble:1.0.1--h779adbc_1' }"
    container 'bioinfo4cabbage/scramble-edited:latest'

    // Edited the "do.dels.R" and "make.vcf.R" scripts during the creation of the Docker image.

    input:
    tuple val(meta), path(clusters)
    path fasta
    path fai

    output:
    tuple val(meta), path("cluster_analysis_files/*_MEIs.txt")                  , optional:true, emit: meis_tab
    tuple val(meta), path("cluster_analysis_files/*_PredictedDeletions.txt")    , optional:true, emit: dels_tab
    //tuple val(meta), path("*.vcf")                                              , optional:true, emit: scramble_vcf
    tuple val(meta), path("*.vcf.gz")                                           , optional:true, emit: scramble_vcfgz
    tuple val(meta), path("*.vcf.gz.tbi")                                       , optional:true, emit: scramble_vcfgztbi
    path "versions.yml"                                                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '1.0.2' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    // def blastdb = args.contains("--eval-dels") ? "makeblastdb -in ${fasta} -parse_seqids -title ${fasta} -dbtype nucl -out ${fasta}" : ""
    def reference = fasta ? "--ref `pwd`/${fasta}" : ""

    // The default file for the MEI reference is a file that's inside the container
    //def mei_reference = mei_ref ? "`pwd`/${mei_ref}" : "/app/cluster_analysis/resources/MEI_consensus_seqs.fa"
    def mei_reference = '/app/cluster_analysis/resources/MEI_consensus_seqs.fa'

    def blastdb_version = "makeblastdb: \$(echo \$(makeblastdb -version 2>&1) | head -n 1 | sed 's/^makeblastdb: //; s/+ Package.*\$//')"
    """    
    makeblastdb -in `pwd`/${fasta} -dbtype nucl

    Rscript --vanilla /app/cluster_analysis/bin/SCRAMble.R \\
        --install-dir /app/cluster_analysis/bin \\
        --cluster-file `pwd`/${clusters} \\
        ${reference} \\
        --mei-refs ${mei_reference} \\
        --out-name `pwd`/${prefix} \\
        --eval-dels \\
        --eval-meis
    
    mkdir cluster_analysis_files
    mv *.txt cluster_analysis_files

    mv ${prefix}.vcf SCRAMBLE_${prefix}.vcf
    bcftools sort SCRAMBLE_${prefix}.vcf > SCRAMBLE_${prefix}_sorted.vcf
    bcftools view SCRAMBLE_${prefix}_sorted.vcf -O z -o SCRAMBLE_${prefix}_sorted.vcf.gz
    bcftools index --tbi SCRAMBLE_${prefix}_sorted.vcf.gz
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scramble: ${VERSION}
        blast_db: ${blastdb_version}
    END_VERSIONS
    """

}
