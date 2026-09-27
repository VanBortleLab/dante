#' Retrieve and combine GEO and SRA metadata
#'
#' Downloads metadata for a GEO series accession and combines information
#' from GEO and the NCBI Sequence Read Archive (SRA). The function identifies
#' the associated SRA study accession (SRP), retrieves SRA RunInfo metadata,
#' maps GEO samples (GSM) to SRA experiments (SRX) and sequencing runs (SRR),
#' and extracts basic GEO sample metadata and sample characteristics.
#'
#' @param gse_name A character string containing a GEO Series accession,
#'   such as `"GSE123456"`.
#'
#' @return A data frame containing combined GEO and SRA metadata. The returned
#'   data frame includes GSM, SRX, and SRR accessions, basic GEO sample
#'   metadata, sequencing run information, and parsed sample characteristics.
#'
#' @details
#' The function performs the following steps:
#'
#' \enumerate{
#'   \item Downloads the GEO Series using \code{GEOquery::getGEO()}.
#'   \item Identifies the associated SRA study (SRP) from the GEO metadata.
#'   \item Downloads SRA RunInfo metadata for the SRP accession.
#'   \item Extracts GSM sample accessions from the GEO Series.
#'   \item Retrieves basic sample metadata, including title, source name,
#'         and organism.
#'   \item Extracts sample characteristics using
#'         \code{\link{extract_characteristics}}().
#'   \item Maps GSM accessions to SRA experiment accessions (SRX).
#'   \item Combines the GEO and SRA information into a single data frame.
#' }
#'
#' @examples
#' \dontrun{
#' metadata <- get_complete_metadata("GSE123456")
#'
#' head(metadata)
#' }
#'
#' @export

get_complete_metadata <- function(gse_name){

  message("---------------------------------------")
  message("Downloading ", gse_name)

  ##########################################################
  ## Download GEO
  ##########################################################

  gse <- GEOquery::getGEO(gse_name,
                GSEMatrix = FALSE)

  ##########################################################
  ## Extract SRP
  ##########################################################

  header <- GEOquery::Meta(gse)

  relation <- header$relation

  srp <- sub(
    ".*(SRP[0-9]+).*",
    "\\1",
    relation[grep("SRP", relation)]
  )

  if(length(srp) == 0)
    stop("No SRP accession found.")

  message("SRP = ", srp)

  ##########################################################
  ## Download RunInfo
  ##########################################################

  url <- paste0(
    "https://trace.ncbi.nlm.nih.gov/Traces/sra-db-be/runinfo?acc=",
    srp
  )

  runinfo <- data.table::fread(url)

  ##########################################################
  ## Get GSM IDs
  ##########################################################

  gsm_list <- GEOquery::GSMList(gse)
  gsm_ids <- names(gsm_list)

  ##########################################################
  ## Basic GSM metadata
  ##########################################################

  gsm_meta <- lapply(gsm_ids, function(id){

    gsm <- gsm_list[[id]]

    md <- GEOquery::Meta(gsm)

    data.frame(

      GSM = id,

      title = ifelse(length(md$title)==0,
                     NA,
                     md$title),

      source_name =
        ifelse(length(md$source_name_ch1)==0,
               NA,
               md$source_name_ch1),

      organism =
        ifelse(length(md$organism_ch1)==0,
               NA,
               md$organism_ch1),

      stringsAsFactors = FALSE

    )

  })

  gsm_meta <- dplyr::bind_rows(gsm_meta)

  ##########################################################
  ## Characteristics
  ##########################################################

  char_df <- lapply(gsm_ids, function(id){

    gsm <- gsm_list[[id]]

    md <- GEOquery::Meta(gsm)

    tmp <- extract_characteristics(
      md$characteristics_ch1
    )

    tmp$GSM <- id

    tmp

  })

  char_df <- dplyr::bind_rows(char_df)

  ##########################################################
  ## Extract SRX accession
  ##########################################################

  gsm_links <- lapply(gsm_ids, function(id){

    gsm <- gsm_list[[id]]

    md <- GEOquery::Meta(gsm)

    rel <- md$relation

    srx <- rel[grep("SRX", rel)]

    if(length(srx)==0){

      srx <- NA

    }else{

      srx <- sub(
        ".*(SRX[0-9]+).*",
        "\\1",
        srx
      )

    }

    data.frame(

      GSM = id,

      SRX = srx,

      stringsAsFactors = FALSE

    )

  })

  gsm_links <- dplyr::bind_rows(gsm_links)

  ##########################################################
  ## Merge everything
  ##########################################################

  metadata <-

    runinfo %>%

    dplyr::rename(

      SRR = Run,

      SRX = Experiment

    ) %>%

    dplyr::left_join(
      gsm_links,
      by="SRX"
    ) %>%

    dplyr::left_join(
      gsm_meta,
      by="GSM"
    ) %>%

    dplyr::left_join(
      char_df,
      by="GSM"
    )

  metadata

}
