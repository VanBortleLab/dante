#' Add FASTQ download URLs to GEO/SRA metadata
#'
#' Reads a metadata file containing SRA run accessions, retrieves FASTQ
#' download information from the European Nucleotide Archive (ENA), and
#' adds the FASTQ URLs to the metadata table.
#'
#' @param metadata_file A character string specifying the path to a metadata
#'   file containing an `SRR` column with SRA run accessions.
#'
#' @return A data frame containing the original metadata with FASTQ download
#'   information added for each unique SRR accession.
#'
#' @details
#' The function reads the metadata file using \code{data.table::fread()},
#' extracts the unique SRR accessions, and uses
#' \code{\link{get_fastq_urls}}() to retrieve FASTQ information for each
#' sequencing run. The resulting FASTQ information is then joined to the
#' original metadata using the SRR accession.
#'
#' @examples
#' \dontrun{
#' metadata <- add_fastq_urls("metadata.csv")
#'
#' head(metadata)
#' }
#'
#' @export


add_fastq_urls <- function(metadata_file){

  if (is.character(metadata)) {
    metadata <- data.table::fread(metadata)
  }

  srrs <- unique(metadata$SRR)

  fastq <- data.table::rbindlist(
    lapply(srrs, get_fastq_urls),
    fill = TRUE
  )

  metadata %>%
    dplyr::left_join(
      fastq,
      by = c("SRR" = "run_accession")
    )

}
