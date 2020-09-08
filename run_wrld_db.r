# Download worldwide score

run_wrld <- function(object) {
  terms <- terms_obj$keyword[terms_obj$batch == object]
  terms <- terms[!(terms %in% dict_obj$term2)]
  time <- time_obj$time[time_obj$batch == object]
  if (.test_empty(table = "data_wrld", batch_o = object)){
    out <- purrr::map_dfr(terms, ~{
      out <- .get_trend(geo = "", term = .x, time = time)
      out <- dplyr::select(out, -geo)
      message(stringr::str_c("run_wrld | term: ", which(terms == .x), "/", length(terms), " complete [", object, "|", max(terms_obj$batch), "]"))
      return(out)
    })  
    out <- dplyr::mutate(out, batch = object)
    DBI::dbWriteTable(conn = gtrends_db, name = "data_wrld", value = out, append = TRUE)
  }
}