process process_convert_bedpe {
    tag "convert_to_bedpe"
    cpus 1
    memory '2 GB'
    container 'beccyl/jaffa:1.09_dev'

    input:
    path jaffa_csv

    output:
    path 'output.bedpe', emit: bedpe

    script:
    """
    # converter script (should be available in /JAFFA inside container)
    /usr/bin/python3 /JAFFA/convert_jaffa_to_bedpe.py ${jaffa_csv} output.bedpe
    """
}
