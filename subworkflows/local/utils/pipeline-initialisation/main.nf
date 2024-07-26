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

include { SAMPLESHEET_CHECK } from '../../../../modules/local/samplesheet_check'
include { CRAMTOBAM } from '../../../../modules/local/cramtobam'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PIPELINE_INITIALISATION {
    
    //
    // Inputs
    //
    take:
    inputsheet        // String: Path to input samplesheet

    main:

    // Creates an initial sample channel to be operated on after splitting the .csv file.
    // ## channel: [sample, mapped, index, mantavcf]
    SAMPLESHEET_CHECK ( inputsheet )
        .csv
        .splitCsv(header:true, sep:',')
        .set { ch_samples }

    // The channel created: ch_samplesheet, would be used for EVIDENCE COLLECTION
    // ## channel: [meta[id, mantavcf], mapped, index]
    ch_samples
        .map {create_samplesheet_channel(it) }
        .set { ch_samplesheet }
    
    // --------------------------------------------------
    // CONVERSION OF INPUT FILES FROM CRAM TO BAM
    if (params.cramtobam) {
        // ## channel: [meta[id, mantavcf], mapped, index]
        CRAMTOBAM (
            ch_samplesheet,
            params.fasta, 
            params.fai
        )[0].set { ch_alignmentfiles }

        // ## channel: [meta[id, mantavcf], mapped, index]
        ch_alignmentfiles
            .filter { it[0].mantavcf == 'false' }
            .set { ch_manta }
    }
    
    // KEEP .CRAM AND .BAM FILES AS THEY ARE - NO CONVERSION.
    if (!params.cramtobam) {
        // ## channel: [meta[id, mantavcf], mapped, index]
        ch_alignmentfiles = ch_samplesheet

        // ## channel: [meta[id], mapped, index]
        ch_samples
            .map { create_manta_channel(it) }
            .filter { it.size() == 3 }
            .set { ch_manta }
    }
    // ==================================================


    // The channel created: ch_skipmanta contains samples that already have the .vcf file produced by Manta upstream,
    // which would later be concatenated with the channel containing the other samples' Manta VCFs after the evidence collection stage, 
    // in preparation for the merging of VCF files in the clustering stage.
    // ## channel: [meta[id], mantavcf]
    ch_samples
        .map { create_manta_channel(it) }
        .filter { it.size() == 2 }
        .set { ch_skipmanta }
    // ch_skipmanta will be used as input for clustering stage...

    emit:
    ch_alignmentfiles
    ch_skipmanta
    ch_manta

}

// For the creation of ch_alignmentmap
// For the creation of ch_manta when params.cramtobam
def create_samplesheet_channel(LinkedHashMap row) {
    def meta = [:]
    meta.id = row.sample
    if (!row.mantavcf) {
        meta.mantavcf = 'false'
    } else {
        meta.mantavcf = 'true'
    }
    sample_metamap = [ meta, file(row.mapped), file(row.index) ]
    return sample_metamap
}

// For the creation of ch_skipmanta 
// For the creation of ch_manta when !params.cramtobam
def create_manta_channel(LinkedHashMap row) {
    def meta = [:]
    meta.id = row.sample
    if (!row.mantavcf) {
        manta_metamap = [ meta, file(row.mapped), file(row.index) ]
    } else {
        manta_metamap = [ meta, file(row.mantavcf) ]
    }
    return manta_metamap
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
