add_fastq_urls <- function(metadata_file){

  metadata <- fread(metadata_file)

  srrs <- unique(metadata$SRR)

  fastq <- rbindlist(
    lapply(srrs, get_fastq_urls),
    fill = TRUE
  )

  metadata %>%
    left_join(
      fastq,
      by = c("SRR" = "run_accession")
    )

}
