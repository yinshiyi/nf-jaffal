#!/usr/bin/env nextflow

/*
 Minimal Nextflow conversion of Oshlack/JAFFA CWL workflow:
  - unpack reference tar
  - run JAFFA via bpipe
  - convert results to bedpe
*/

//cwl/jaffa.cwl (CWL CommandLineTool that runs bpipe)
// cwl/smcFusion-jaffa-workflow.cwl (CWL Workflow wiring tar → jaffa → converter)
// cwl/tar.cwl (untar step)
// cwl/converter.cwl (convert JAFFA CSV → BEDPE)
// cwl/twoBitToFa.cwl (helper)
// JAFFA_direct.groovy, JAFFA_stages.groovy, JAFFA_assembly.groovy, JAFFA_hybrid.groovy, JAFFAL.groovy (the bpipe pipeline scripts)
// install_linux64.sh / Dockerfile (how the image is built; container ENTRYPOINT is bpipe run)

params.reference_tar = null      // path to jaffa_reference tar.gz (or a folder if you already unpacked)
params.reference_dir = '/wgbs/scratch/syin/LRS74/BT474-demo/'    // dir inside container with reference files (map host -> container)
params.pipeline = '/wgbs/scratch/syin/LRS74/JAFFA/JAFFA_direct.groovy' // set to the pipeline inside the container
params.genomeFasta = null
params.fastq =  '/wgbs/scratch/syin/LRS74/BT474-demo/'
params.fastqInputFormat = '%_*.fq.gz'
params.genome = 'GRCh37'
params.annotation = '75'
params.threads = 2

include { process_run_jaffa } from './modules/process_run_jaffa.nf'
include { process_convert_bedpe } from './modules/process_convert_bedpe.nf'

workflow {
    // If you already have a reference directory, you can skip the tar step and set ref_ch accordingly.
    ref_ch = Channel.fromPath(params.reference_dir)
    // Channel.fromPath(params.reference_tar)
    //     .ifEmpty {  }

    // Step 1: unpack reference tar (if a tar is provided)
    // unpacked_ref = ref_ch
    //     .map { file -> file }
    //     .set { ref_input }

    // If reference is a tar, run tar process; if it's a directory path, pass through
    // ref_dir_ch = Channel.create()
    // ref_input.subscribe { f ->
    //     if( f.name.endsWith('.tar.gz') || f.name.endsWith('.tgz') ) {
    //         ref_dir_ch << f
    //     } else {
    //         // assume directory already
    //         ref_dir_ch << f
    //     }
    // }

    // // For simplicity, call tar process only if input is a tar.gz
    // ref_ready = ref_dir_ch
    //     .map { f -> f }  // forward to jaffa step; process will handle tar vs dir
    //     .set { ref_ready_ch }

    // Step 2: run JAFFA (bpipe)
    jaffa_in_ch = ref_ch.combine(Channel.fromPath(params.fastq))


    jaffa_out = process_run_jaffa(jaffa_in_ch).jaffa_csv

    // Step 3: convert to bedpe
    process_convert_bedpe( jaffa_out )
}


