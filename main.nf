#!/usr/bin/env nextflow

include { filter_transcripts } from './modules/filter_transcripts.nf'
include { get_fasta } from './modules/get_fasta.nf'
include { get_final_list } from './modules/get_final_list.nf'
include { minimap2_transcriptome } from './modules/minimap2_transcriptome.nf'
include { extract_fusion_sequences } from './modules/extract_fusion_sequences.nf'
include { make_fasta_reads_table } from './modules/make_fasta_reads_table.nf'
include { minimap2_genome } from './modules/minimap2_genome.nf'
include { report_3_gene_fusions } from './modules/report_3_gene_fusions.nf'

workflow {

    jaffa_in_ch = Channel.fromPath("${params.fastq}/*.fastq.gz")
                        .map { f -> tuple(f.simpleName, f) }
    fasta_ch = get_fasta(jaffa_in_ch)
    paf_ch = minimap2_transcriptome(fasta_ch)
    txt_ch = filter_transcripts(paf_ch)

    txt_ch.join(fasta_ch) \
        | extract_fusion_sequences \
        | set{fusion_fa_ch}

    psl_ch = minimap2_genome(fusion_fa_ch)

    txt_ch \
        | make_fasta_reads_table \
        | set{reads_ch}

    psl_ch.join(reads_ch) \
        | get_final_list \
        | set{summary_ch}

    summary_ch.join(txt_ch) \
        | report_3_gene_fusions

}


