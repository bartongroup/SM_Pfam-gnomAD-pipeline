import glob

rule all:
    input:
        expand("output/{dir}/{id}/{id}.sto.log", dir=["0"], id=["PF00001_20"])

rule get_data:
    input:
        "data/Pfam-A.seed.gz"

# rule all:
#     input:
#         expand("output/{dir}/{id}/{id}.sto", dir=["0", "0"], id=["PF00001_20", "PF00002_23"])

# rule all:
#     input:
#         expand("{base}_processed.txt",
#         base=[s.replace('.sto', '') for s in glob.glob('output/*/*/*.sto')])

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

def generate_execute_tool_input(wildcards):
    dir_pattern = f"output/{wildcards.dir}"
    dir_id_pattern = f"{dir_pattern}/{wildcards.id}/{wildcards.id}.sto"
    return expand(dir_id_pattern, dir=glob.glob(f"{dir_pattern}/*"), id="PF*")

rule execute_tool:
    conda:
        "environment.yml"
    input:
        generate_execute_tool_input
    output:
        "output/{dir}/{id}/{id}.sto.log"
    shell:
        """
        cp varalign-config.txt $(dirname {output})/config.txt
        cd $(dirname {output})
        ln -sf ../../../data/ data
        # filter_swiss $(basename {input})
        cp data/sample_swissprot_PF00001.18_full.sto swissprot_$(basename {input})
        varalign swissprot_$(basename {input}) > swissprot_$(basename {output})
        """
