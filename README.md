# Dante 

## Retrieve GEO metadata and FASTQ download URLs

`Dante` is an R package for retrieving and combining metadata from NCBI Gene Expression Omnibus (GEO) and Sequence Read Archive (SRA), and for obtaining FASTQ download URLs from the European Nucleotide Archive (ENA). Inspired from Dante's Inferno, Dante will help you to go through the 'messy' metadata and to recover the 'soul' of it - the FASTQ files!

The package is designed to simplify the process of going from a GEO study accession (GSE) to an analysis-ready metadata table containing GSM, SRX, SRR, sequencing information, and FASTQ download URLs.

## Features

`Dante` currently provides functions to:

- Retrieve GEO study metadata from a GSE accession.
- Identify the corresponding SRA study (SRP).
- Retrieve SRA RunInfo metadata.
- Map GEO samples (GSM) to SRA experiments (SRX).
- Map SRA experiments (SRX) to sequencing runs (SRR).
- Parse GEO sample characteristics into separate metadata columns.
- Retrieve FASTQ URLs from ENA using SRR accessions.
- Add FASTQ URLs directly to the combined GEO/SRA metadata table. 
         fastq_ftp : for downloading FASTQ files
         fastq_aspera : for alternative download of FASTQ files (fast download)
         fastq_md5 : for integrity check and verifying the download of FASTQ files



## Workflow

```mermaid
flowchart TD
    A["GSE accession"] --> B["GEO metadata"]
    B --> C["Identify corresponding SRA study (SRP)"]
    C --> D["Retrieve SRA RunInfo metadata"]
    D --> E["Map GSM → SRX → SRR"]
    E --> F["Parse sample characteristics"]
    F --> G["Retrieve FASTQ URLs from ENA"]
    G --> H["Combined GEO/SRA metadata table"]

    style A fill:#fce4e4,stroke:#b22222,color:#222
    style H fill:#e2f0e2,stroke:#39804a,color:#222
```

## Installation

### Development version from GitHub

The package is currently under development.

To install the development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("VanBortleLab/dante")
```

