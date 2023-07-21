import glob

rule all:
    input:
        expand("output/{dir}/{id}/{id}.sto.log", dir=["0"], id=["PF00001_20"])

rule get_data:
    input:
        "data/downloads/pfam/Pfam-A.seed.gz",
        "data/downloads/gnomad/gnomad.exomes.r2.1.1.sites.22.vcf.bgz",
        "data/downloads/gnomad/gnomad.exomes.r2.1.1.sites.22.vcf.bgz.tbi"

# rule all:
#     input:
#         expand("output/{dir}/{id}/{id}.sto", dir=["0", "0"], id=["PF00001_20", "PF00002_23"])

# rule all:
#     input:
#         expand("{base}_processed.txt",
#         base=[s.replace('.sto', '') for s in glob.glob('output/*/*/*.sto')])

rule download_pfam:
    output:
        "data/downloads/pfam/Pfam-A.seed.gz"
    params:
        url = "http://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam31.0/Pfam-A.seed.gz"
    shell:
        """
        curl -C - {params.url} -o {output}
        """
rule download_gnomad:
    output:
        "data/downloads/gnomad/gnomad.exomes.r2.1.1.sites.22.vcf.bgz"
    params:
        url = "https://storage.googleapis.com/gcp-public-data--gnomad/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.22.vcf.bgz"
    shell:
        """
        curl -C - {params.url} -o {output}
        """

rule download_gnomad_index:
    output:
        "data/downloads/gnomad/gnomad.exomes.r2.1.1.sites.22.vcf.bgz.tbi"
    params:
        url = "https://storage.googleapis.com/gcp-public-data--gnomad/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.22.vcf.bgz.tbi"
    shell:
        """
        curl -C - {params.url} -o {output}
        """

rule split_pfam:
    input:
        "data/downloads/pfam/Pfam-A.seed.gz"
    output:
        directory("output")
    params:
        n = 100
    script:
        "scripts/split_pfam.py"

# VEP options:
# Default CSQ Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_position|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND|FLAGS|SYMBOL_SOURCE|HGNC_ID
# --fields "Allele,Consequence,Feature_type,Feature"
rule annotate_variants:
    conda:
        "environment-vep.yml"
    input:
        "data/downloads/gnomad/gnomad.exomes.r2.1.1.sites.22.vcf.bgz"
    output:
        "data/processed/gnomad/gnomad.exomes.r2.1.1.sites.22.vep.vcf.bgz"
    log: 
        out = 'data/processed/gnomad/vep_stdout.log',
        err = 'data/processed/gnomad/vep_stderr.err'
    shell:
        """
        vep_install -a cf -s homo_sapiens -y GRCh37 -c resources/vep —CONVERT
        vep --verbose --fork 4 --cache --dir_cache "resources/vep" -a GRCh37 --offline --compress_output bgzip \
            --vcf --variant_class --uniprot --canonical --biotype --ccds --coding_only \
            -i {input} -o {output} 2> {log.err} 1> {log.out}
        """

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
