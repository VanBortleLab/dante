get_complete_metadata <- function(gse_name){

  message("---------------------------------------")
  message("Downloading ", gse_name)

  ##########################################################
  ## Download GEO
  ##########################################################

  gse <- getGEO(gse_name,
                GSEMatrix = FALSE)

  ##########################################################
  ## Extract SRP
  ##########################################################

  header <- Meta(gse)

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

  runinfo <- fread(url)

  ##########################################################
  ## Get GSM IDs
  ##########################################################

  gsm_ids <- names(GSMList(gse))

  ##########################################################
  ## Basic GSM metadata
  ##########################################################

  gsm_meta <- lapply(gsm_ids, function(id){

    gsm <- GSMList(gse)[[id]]

    md <- Meta(gsm)

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

  gsm_meta <- bind_rows(gsm_meta)

  ##########################################################
  ## Characteristics
  ##########################################################

  char_df <- lapply(gsm_ids, function(id){

    gsm <- GSMList(gse)[[id]]

    md <- Meta(gsm)

    tmp <- extract_characteristics(
      md$characteristics_ch1
    )

    tmp$GSM <- id

    tmp

  })

  char_df <- bind_rows(char_df)

  ##########################################################
  ## Extract SRX accession
  ##########################################################

  gsm_links <- lapply(gsm_ids, function(id){

    gsm <- GSMList(gse)[[id]]

    md <- Meta(gsm)

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

  gsm_links <- bind_rows(gsm_links)

  ##########################################################
  ## Merge everything
  ##########################################################

  metadata <-

    runinfo %>%

    rename(

      SRR = Run,

      SRX = Experiment

    ) %>%

    left_join(
      gsm_links,
      by="SRX"
    ) %>%

    left_join(
      gsm_meta,
      by="GSM"
    ) %>%

    left_join(
      char_df,
      by="GSM"
    )

  metadata

}
