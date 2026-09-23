get_fastq_urls <- function(srr){

  url <- paste0(
    "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=",
    srr,
    "&result=read_run",
    "&fields=run_accession,fastq_ftp,fastq_aspera,fastq_md5",
    "&format=tsv"
  )
  x <- fread(url)

  x

}
