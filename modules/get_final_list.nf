process get_final_list {

    tag "$sample"
    publishDir "${params.outdir}/${sample}", mode: 'copy'

    input:
    tuple val(sample), path(psl), path(reads)

    output:
    tuple val(sample), path("${sample}.summary")

    script:
    """
    Rscript ${params.R_get_final_list} \
        $psl \
        $reads \
        ${params.transTable} \
        ${params.knownTable} \
        ${params.finalGapSize} \
        ${params.exclude} \
        ${params.reassign_dist} \
        ${sample}.summary
    """
}
