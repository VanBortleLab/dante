#' Retrieve FASTQ download URLs from ENA
#'
#' Given one or more SRA run accessions, retrieve FASTQ download
#' URLs from the European Nucleotide Archive (ENA).
#'
#' @param srr Character vector of SRR accessions.
#'
#' @return A data frame containing SRR accessions and FASTQ URLs.
#'
#' @examples
#' \dontrun{
#' get_fastq_urls("SRR123456")
#' }
#'
#' @export


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
