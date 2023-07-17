# A unified approach to evolutionary conservation and population constraint in proteins

Repository containing piepline to generate the data uderpinning "A unified approach to evolutionary conservation and population constraint in proteins".

# Overview

This pipeline generates the dataset that underpins our unified analysis of evolutionary conservation and population constraint in protein domains. Our method relies on a data model where each position in a protein domain, which are represented by the columns of a multiple sequence alignment, is annotated with features that quantify the conservation, variability and structural properties of the site across the whole family. We acheive this by integrating data from multiple sources, including protein sequence alignments, protein structures, and human genetic variation, using a series of python packages we have developed for this purpose.

In this instance, we integrate data from the following databases:

- [Pfam-A](https://pfam.xfam.org/) database of protein families (version 31.0)
- [gnomAD](https://gnomad.broadinstitute.org/) database of human genetic variation (version 2.1.1).
- [ClinVar](https://www.ncbi.nlm.nih.gov/clinvar/) database of human genetic variants and their clinical significance.
- [PDBe](https://www.ebi.ac.uk/pdbe/) database of protein structures.

For each Pfam domain we compute the following features:
- Conservation: 18 conservation scores are computed with [AACon](https://www.compbio.dundee.ac.uk/aacon/).
- Population constraint: missense variants from gnomAD are mapped to each domain and the Missense Enrichment Score is computed.
- Structural features: relevant PDB entries are found with [SIFTS](https://www.ebi.ac.uk/pdbe/docs/sifts/) and we map residue contacts, secondary structure and solvent accessibility to each domain position.
- Clinical features: missense variants from ClinVar are mapped to each domain and the total number of pathogenic variants is computed.

These are then processed into a single dataset of aggregated statistics for each Pfam domain, which is provided in data/pfam-gnomAD-clinvar-pdb-colstats_c7c3e19.csv.gz.

Further information on the methods used to generate the dataset can be found in the manuscript, while details of the core python packages can be found in their respective repositories (see below).

## Links to core python packages

- [VarAlign](https://github.com/bartongroup/SM_VarAlign)
- [ProIntVar](https://github.com/bartongroup/ProIntVar)
- [ProteoFAV](https://github.com/bartongroup/ProteoFAV)

# Setup

First install [conda](https://docs.conda.io/en/latest/miniconda.html) and then run the following commands:

```bash
conda env create -f environment.yml
conda activate SM_Pfam-gnomAD-pipeline
```

# Usage

```bash
varalign --help
```

# Pipeline

```bash
 snakemake -p -j 1 --use-conda split_pfam
 snakemake -p -j 1 --use-conda
```
