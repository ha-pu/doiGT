#' @title Export data from database table
#'
#' @description
#' The function allows to export data from database tables. In combination with
#' various *write* functions in R, the functions allow exports from the
#' database to local files.
#'
#' @details
#' Exports can be filtered by *keyword*, *object*, *control*,
#' *locations*, or *type*. Not all filters are applicable for all
#' functions. When filter *keyword* and *object* are used together,
#' *keyword* overrules *object*. Currently the functions do not
#' include list inputs - users are advised to `purrr::map_dfr` or
#' `dplyr::filter` instead.
#'
#' @param keyword Object keywords for which data should be exported. Object of
#' type `character`.
#' @param object Object batch number for which data should be exported.
#' @param control Control batch number for which data should be exported.
#' @param locations List of locations for which the search score is used.
#' For `export_control`, `export_object`, or `export_score`
#' refers to lists generated in `start_db`. For `export_doi`
#' object of type `character`.
#' @param type Type of time series for which data should be exported. Element
#' of type `character`. Relevant only for `export_global` and
#' `export_doi`. Takes one of the following values: *obs` - observed
#' search scores, *sad* - seasonally adjusted search scores, *trd* -
#' trend only search scores.
#'
#' @return
#' The functions export and filter the respective database tables.
#' \itemize{
#'   \item `export_control` exports data from table *data_control` with
#' columns location, keyword, date, hits, control. Object of class
#' `"data.frame"`.
#'   \item `export_object` exports data from table *data_object` with
#' columns location, keyword, date, hits, object.Object of class
#' `"data.frame"`.
#'   \item `export_score` exports data from table *data_score` with
#' columns location, keyword, date, score_obs, score_sad, score_trd, control,
#' object. Object of class `c("exp_score", "data.frame")`.
#'   \item `export_voi` exports data from table *data_score` with
#' columns keyword, date, hits, control, filters for
#' `location == "world"`. Object of class
#' `c("exp_voi", "data.frame")`.
#'   \item `export_doi` exports data from table *data_doi` with columns
#' keyword, date, type, gini, hhi, entropy, control, object, locations. Object
#' of class `c("exp_doi", "data.frame")`.
#' }
#'
#' @seealso
#' * [data_control()]
#' * [data_object()]
#' * [data_score()]
#' * [data_doi()]
#' * [purrr::map()]
#' * [dplyr::filter()]
#'
#' @examples
#' \dontrun{
#' export_control(control = 2)
#'
#' export_object(
#'   keyword = "manchester united",
#'   locations = countries
#' )
#'
#' export_score(
#'   object = 3,
#'   control = 1,
#'   locations = us_states
#' ) %>%
#'   readr::write_csv("data_score.csv")
#'
#' export_doi(
#'   keyword = "manchester united",
#'   control = 2,
#'   type = "sad",
#'   locations = "us_states"
#' ) %>%
#'   writexl::write_xlsx("data_doi.xlsx")
#'
#' # interaction with purrr::map_dfr
#' purrr::map_dfr(
#'   c("coca cola", "microsoft"),
#'   export_doi,
#'   control = 1,
#'   type = "obs"
#' )
#'
#' # interaction with dplyr::filter
#' export_voi(
#'   object = 1,
#'   control = 1,
#'   type = "obs"
#' ) %>%
#'   dplyr::filter(lubridate::year(date) == 2019)
#' }
#'
#' @rdname export_data
#' @export
#' @importFrom dplyr filter
#' @importFrom dplyr rename
#' @importFrom dplyr select
#' @importFrom rlang .data
#' @importFrom glue glue

export_control <- function(control = NULL, locations = NULL) {
  out <- .export_data_single(
    table = .tbl_control,
    in_control = control
  )
  if (!is.null(locations)) {
    in_location <- locations
    out <- filter(out, .data$location %in% in_location)
  }
  out <- filter(out, .data$location != "world")
  out <- rename(out, control = .data$batch)
  return(out)
}

#' @rdname export_data
#' @export

export_control_global <- function(control = NULL) {
  out <- .export_data_single(
    table = .tbl_control,
    in_control = control
  )
  out <- filter(out, .data$location == "world")
  out <- rename(out, control = .data$batch)
  return(out)
}

#' @rdname export_data
#' @export

export_object <- function(keyword = NULL, object = NULL, control = NULL, locations = NULL) {
  out <- .export_data_double(
    table = .tbl_object,
    in_keyword = keyword,
    in_object = object,
    in_control = control
  )
  if (!is.null(locations)) {
    in_location <- locations
    out <- filter(out, .data$location %in% in_location)
  }
  out <- filter(out, .data$location != "world")
  out <- rename(out, object = .data$batch_o, control = .data$batch_c)
}

#' @rdname export_data
#' @export

export_object_global <- function(keyword = NULL, object = NULL, control = NULL) {
  out <- .export_data_double(
    table = .tbl_object,
    in_keyword = keyword,
    in_object = object,
    in_control = control
  )
  out <- filter(out, .data$location == "world")
  out <- rename(out, object = .data$batch_o, control = .data$batch_c)
  return(out)
}

#' @rdname export_data
#' @export

export_score <- function(keyword = NULL, object = NULL, control = NULL, locations = NULL) {
  out <- .export_data_double(
    table = .tbl_score,
    in_keyword = keyword,
    in_object = object,
    in_control = control
  )
  if (!is.null(locations)) {
    in_location <- locations
    out <- filter(out, .data$location %in% in_location)
  }
  out <- filter(out, .data$location != "world")
  out <- rename(out, control = .data$batch_c, object = .data$batch_o)
  out <- select(out, -.data$synonym)
  class(out) <- c("exp_score", class(out))
  return(out)
}

#' @rdname export_data
#' @export

export_voi <- function(keyword = NULL, object = NULL, control = NULL) {
  out <- .export_data_double(
    table = .tbl_score,
    in_keyword = keyword,
    in_object = object,
    in_control = control
  )
  out <- filter(out, .data$location == "world")
  out <- rename(out, control = .data$batch_c, object = .data$batch_o)
  out <- select(out, -.data$synonym)
  class(out) <- c("exp_voi", class(out))
  return(out)
}

#' @rdname export_data
#' @export

export_doi <- function(keyword = NULL, object = NULL, control = NULL, locations = NULL, type = NULL) {
  out <- .export_data_double(
    table = .tbl_doi,
    in_keyword = keyword,
    in_object = object,
    in_control = control,
    in_locations = locations,
    in_type = type
  )
  out <- rename(out, control = .data$batch_c, object = .data$batch_o)
  class(out) <- c("exp_doi", class(out))
  return(out)
}

#' @title Run export data from database tables
#'
#' @rdname dot-export_data
#'
#' @keywords internal
#' @noRd
#'
#' @importFrom dplyr collect
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom lubridate as_date

.export_data_single <- function(table, in_keyword = NULL, in_object = NULL, in_control = NULL, in_type = NULL) {
  keyword <- in_keyword
  object <- in_object
  control <- in_control
  .check_length(keyword, 1)
  .check_length(object, 1)
  .check_length(control, 1)
  if (!is.null(in_type)) .check_type(in_type)

  if (!is.null(in_keyword)) .check_input(keyword, "character")
  if (is.null(in_keyword) & !is.null(in_object)) .check_batch(in_object)
  if (!is.null(in_control)) .check_batch(in_control)

  if (!is.null(in_type)) in_type <- paste0("hits_", in_type)
  if (!is.null(in_keyword)) table <- filter(table, .data$keyword == in_keyword)
  if (is.null(in_keyword) & !is.null(in_object)) table <- filter(table, .data$batch == in_object)
  if (!is.null(in_control)) table <- filter(table, .data$batch == in_control)
  if (!is.null(in_type)) table <- filter(table, .data$type == in_type)

  table <- collect(table)
  table <- mutate(table, date = as_date(.data$date))
  return(table)
}

#' @rdname dot-export_data
#'
#' @keywords internal
#' @noRd
#'
#' @importFrom dplyr collect
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom lubridate as_date

.export_data_double <- function(table, in_keyword = NULL, in_object = NULL, in_control = NULL, in_locations = NULL, in_type = NULL) {
  keyword <- in_keyword
  object <- in_object
  control <- in_control
  locations <- in_locations
  .check_length(keyword, 1)
  .check_length(object, 1)
  .check_length(control, 1)
  .check_length(locations, 1)
  if (!is.null(in_type)) .check_type(in_type)

  if (!is.null(in_keyword)) .check_input(keyword, "character")
  if (is.null(in_keyword) & !is.null(in_object)) .check_batch(in_object)
  if (!is.null(in_control)) .check_batch(in_control)
  if (!is.null(in_locations)) .check_input(locations, "character")

  if (!is.null(in_type)) in_type <- paste0("score_", in_type)
  if (!is.null(in_keyword)) table <- filter(table, .data$keyword == in_keyword)
  if (is.null(in_keyword) & !is.null(in_object)) table <- filter(table, .data$batch_o == in_object)
  if (!is.null(in_control)) table <- filter(table, .data$batch_c == in_control)
  if (!is.null(in_locations)) table <- filter(table, .data$locations == in_locations)
  if (!is.null(in_type)) table <- filter(table, .data$type == in_type)

  table <- collect(table)
  table <- mutate(table, date = as_date(.data$date))
  return(table)
}
