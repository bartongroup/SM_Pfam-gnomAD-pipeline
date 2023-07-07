rule download_pfam:
    output:
        "data/Pfam-A.seed.gz"
    params:
        url = "http://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.seed.gz"
    shell:
        """
        curl -C - {params.url} -o {output}
        """

rule split_pfam:
    input:
        "data/Pfam-A.seed.gz"
    output:
        directory("output")
    params:
        n = 100
    script:
        "scripts/split_pfam.py"
