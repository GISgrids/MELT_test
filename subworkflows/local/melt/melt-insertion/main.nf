#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/testmelt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/testmelt
    Website: https://nf-co.re/testmelt
    Slack  : https://nfcore.slack.com/channels/testmelt
----------------------------------------------------------------------------------------
*/


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// TODO nf-core: Remove this line if you don't need a FASTA file
//   This is an example of how to use getGenomeAttribute() to fetch parameters
//   from igenomes.config using `--genome`
// params.fasta = getGenomeAttribute('fasta')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MELT_INS_PREPROCESS } from '../../../../modules/local/melt/ins_preprocess' 
include { MELT_INS_INDIVANALYSIS } from '../../../../modules/local/melt/ins_indivanalysis' 
include { MELT_INS_GROUPANALYSIS } from '../../../../modules/local/melt/ins_groupanalysis' 
include { MELT_INS_GENOTYPE } from '../../../../modules/local/melt/ins_genotype' 
include { MELT_INS_MAKEVCF } from '../../../../modules/local/melt/ins_makevcf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Uncomment this during when the pipeline is fully ready.
//mobileElements_ins_ch = Channel.of("ALU", "HERVK", "LINE1", "SVA")

// Using this line to create the mobileElements_ins channel for testing purposes, 
// as there were no ME insertions of SVA and HERVK for the 3 samples being tested, which caused MELT to fail.
mobileElements_ins_ch = Channel.of("ALU", "LINE1")

workflow MELT_INSERTION {
    
    // Inputs
	take:
    samplesheet
    

    // Modules 
    main:

    MELT_INS_PREPROCESS (
        samplesheet, 
        params.fasta, 
        params.fai
    )

    MELT_INS_INDIVANALYSIS (
        MELT_INS_PREPROCESS.out.meltpreprocess_ch,
        mobileElements_ins_ch,
        params.fasta, 
        params.fai
    )

    MELT_INS_GROUPANALYSIS (
        MELT_INS_INDIVANALYSIS.out.meltindivanalysis_bam_ch.collect(),
        MELT_INS_INDIVANALYSIS.out.meltindivanalysis_bed_ch.collect(),
        mobileElements_ins_ch,
        params.fasta, 
        params.fai
    )

    MELT_INS_GENOTYPE (
        samplesheet,
        MELT_INS_GROUPANALYSIS.out.meltgroupanalysis_ch.collect(),
        mobileElements_ins_ch,
        params.fasta, 
        params.fai
    )

    MELT_INS_MAKEVCF (
        MELT_INS_GROUPANALYSIS.out.meltgroupanalysis_ch.collect(),
        MELT_INS_GENOTYPE.out.meltgenotype_ch.collect(),
        mobileElements_ins_ch,
        params.fasta, 
        params.fai
    )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
