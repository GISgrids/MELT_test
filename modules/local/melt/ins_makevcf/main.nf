process MELT_INS_MAKEVCF {
  
    tag "MELT-Insertion-MakeVCF"
    label 'process_low'

    // ### The template commands for loading containers have been commented out. ###
    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/melt:1.0.3--py36_2':
    //    'biocontainers/melt:1.0.3--py36_2' }"
    //conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container 'docker.io/bioinfo4cabbage/melt:1.0'

    input:
    path meltgroupanalysis_ch
    path meltgenotype_ch
    each mobileElementIns
    path fasta
    path fai

    output:
    //path("*/*/*.vcf")               , emit: meltmakevcf_ch
    path("*/*/*.vcf.gz")                    , emit: meltmakevcfgz_ch
    path("*/*/*.vcf.gz.tbi")                , emit: meltmakevcfgz_tbi_ch
    path "versions.yml"                     , emit: versions

    when: 
    task.ext.when == null || task.ext.when

    //
    // What are the files required?
    // Step 3 GroupAnalysis output
    // Step 4 Genotyping output
    //

    //
    // This step will create a single VCF file for each ME type (i.e. LINE1, ALU, SVA, etc.) 
    // 

    script:
    def args = task.ext.args ?: ''
    def MELT_VERSION = '2.2.2'
    
    """
    mkdir -p ${mobileElementIns}_DISCOVERY/FINAL_VCF ${mobileElementIns}_DISCOVERY/GroupAnalysis ${mobileElementIns}_DISCOVERY/Genotype
    mv *${mobileElementIns}.tsv ${mobileElementIns}_DISCOVERY/Genotype
    mv ${mobileElementIns}.* ${mobileElementIns}_DISCOVERY/GroupAnalysis

    java -Xmx6G -jar /opt/MELT.jar MakeVCF \\
        $args \\
        -genotypingdir ${mobileElementIns}_DISCOVERY/Genotype \\
        -h ${fasta} \\
        -t /opt/me_refs/Hg38/${mobileElementIns}_MELT.zip \\
        -w ${mobileElementIns}_DISCOVERY/FINAL_VCF \\
        -p ${mobileElementIns}_DISCOVERY/GroupAnalysis \\
        -o ${mobileElementIns}_DISCOVERY/FINAL_VCF
    
    mv ${mobileElementIns}_DISCOVERY/FINAL_VCF/${mobileElementIns}.final_comp.vcf ${mobileElementIns}_DISCOVERY/FINAL_VCF/MELT_Insertion_${mobileElementIns}_merged.vcf
    bcftools sort ${mobileElementIns}_DISCOVERY/FINAL_VCF/MELT_Insertion_${mobileElementIns}_merged.vcf > ${mobileElementIns}_DISCOVERY/FINAL_VCF/MELT_Insertion_${mobileElementIns}_merged_sorted.vcf
    bcftools view ${mobileElementIns}_DISCOVERY/FINAL_VCF/MELT_Insertion_${mobileElementIns}_merged_sorted.vcf -O z \\
        -o ${mobileElementIns}_DISCOVERY/FINAL_VCF/MELT_Insertion_${mobileElementIns}_merged_sorted.vcf.gz
    bcftools index --tbi ${mobileElementIns}_DISCOVERY/FINAL_VCF/MELT_Insertion_${mobileElementIns}_merged_sorted.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MELT: ${MELT_VERSION}
    END_VERSIONS
    """

    stub: 
    def args = task.ext.args ?: ''
    def MELT_VERSION = '2.2.2'
    
    """
    mkdir -p ${mobileElementIns}_DISCOVERY/FINAL_VCF

    touch ${mobileElementIns}_DISCOVERY/FINAL_VCF/MELT_Insertion_${mobileElementIns}_merged_sorted.vcf
    touch ${mobileElementIns}_DISCOVERY/FINAL_VCF/MELT_Insertion_${mobileElementIns}_merged_sorted.vcf.gz
    touch ${mobileElementIns}_DISCOVERY/FINAL_VCF/MELT_Insertion_${mobileElementIns}_merged_sorted.vcf.gz.tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MELT: ${MELT_VERSION}
    END_VERSIONS
    """
    
}

