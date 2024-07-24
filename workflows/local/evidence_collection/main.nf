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

include { CRAMTOBAM } from '../../../modules/local/cramtobam'
include { MELT_DELETION } from '../../../subworkflows/local/melt/melt-deletion' 
include { MELT_INSERTION } from '../../../subworkflows/local/melt/melt-insertion' 
include { SCRAMBLE } from '../../../subworkflows/local/scramble'
include { WHAMG } from '../../../subworkflows/local/whamg'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow EVIDENCE_COLLECTION {
    
    take:
    ch_samplesheet

    main:

    // --------------------------------------------------
    // STEP 1: CONVERSION OF INPUT FILES FROM CRAM TO BAM
    // A new channel: ch_alignmentfiles, would be created regardless.
    // 
    if (params.cramtobam) {
        CRAMTOBAM (
            ch_samplesheet,
            params.fasta, 
            params.fai
        ).set { ch_alignmentfiles }
    }

    if (!params.cramtobam) {
        ch_alignmentfiles = ch_samplesheet
    }
    // ==================================================
    

    // --------------------------------------------------
    // STEP 2: RUNNING MELT INSERTION FOR NOVEL ME DISCOVERY AND MELT DELETION
    //
    MELT_INSERTION ( ch_alignmentfiles )

    MELT_DELETION ( ch_alignmentfiles )
    // ==================================================

    
    // --------------------------------------------------
    // STEP 3:
    //
    if (params.cramtobam) {
        WHAMG ( ch_alignmentfiles )
    }
    // ==================================================


    // --------------------------------------------------
    // STEP 4: RUNNING SCRAMBLE
    // 
    SCRAMBLE ( ch_alignmentfiles )
    // ==================================================

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
