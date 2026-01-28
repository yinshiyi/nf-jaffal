process process_run_jaffa {
    tag "${task.cpus}cpus - ${params.pipeline}"
    cpus params.threads
    memory '8 GB'
    container 'beccyl/jaffa:1.09_dev'   // use the same image as CWL or your built image
    publishDir "${task.workDir}/out", mode: 'copy'

    input:
    tuple val(ref), path(fq1)

    output:
    path 'jaffa_results.csv' , emit: jaffa_csv
    path 'jaffa_results.fasta' , emit: jaffa_fasta
    path 'log.txt' , emit: jaffa_log

    script:
    """
    # Run bpipe; preserve argument order similar to CWL:
    /JAFFA/tools/bin/bpipe run ${params.pipeline} -n ${task.cpus} refBase=${ref} genomeFasta=${params.genomeFasta ?: ''} fastqInputFormat=${params.fastqInputFormat} genome=${params.genome} annotation=${params.annotation} ${fq1} > log.txt 2>&1
    """
}
