#' @title Download data for control batch
#'
#' @aliases
#' run_control
#' run_control.numeric
#' run_control.list
#'
#' @description
#' @details
#'
#' @param control Control batch for which the data is downloaded. Object
#' of class \code{numeric} or object of class \code{list} containing single
#' elements of class \code{numeric}.
#' @param lst_geo List of countries or regions for which the data is downloaded.
#' Refers to lists generated in \code{start_db}.
#'
#' @seealso
#'
#' @return
#' Message that data was downloaded successfully. Data is uploaded
#' to data_control.
#'
#' @examples
#' \dontrun{
#' data_con(control = 1, lst_geo = lst_wdi)
#' data_con(control = as.list(1:5), lst_geo = lst_wdi)
#' }
#'
#' @export
#' @rdname run_control
#' @importFrom DBI dbWriteTable
#' @importFrom dplyr mutate
#' @importFrom glue glue
#' @importFrom purrr walk

run_control <- function(control, lst_geo = lst_wdi) UseMethod("run_control", control)

#' @rdname run_control
#' @method run_control numeric
#' @export

run_control.numeric <- function(control, lst_geo = lst_wdi) {
  .test_batch(control)
  terms <- terms_con$keyword[terms_con$batch == control]
  time <- time_con$time[time_con$batch == control]
  walk(lst_geo, ~ {
    if (.test_empty(table = "data_con", batch_c = control, geo = .x)) {
      out <- .get_trend(geo = .x, term = terms, time = time)
      if (!is.null(out)) {
        out <- mutate(out, batch = control)
        dbWriteTable(conn = doiGT_DB, name = "data_con", value = out, append = TRUE)
      }
    }
    message(glue("Successfully downloaded control data | control: {control} | geo: {.x} [{current}/{total}]", current = which(lst_geo == .x), total = length(lst_geo)))
  })
}

#' @rdname run_control
#' @method run_control list
#' @export

run_control.list <- function(control, lst_geo = lst_wdi) {
  walk(control, run_control, lst_geo = lst_geo)
}
