#' @title Boxplot of DOI time series
#'
#' @description
#' The function uses the output of \code{export_doi} to prepare a box plot of
#' the distribution of degree of internationalization values. When the output
#' includes more than nine keywords, only the first nine keywords are used.
#'
#' @param data_doi Data exported from \code{export_doi} function.
#' @param type Object of class \code{character} indicating the type of time
#' series-column from data_score that is used for DOI computation, takes
#' either \emph{obs}, \emph{sad}, or \emph{trd}. Defaults to \emph{"obs"}.
#' @param measure Object of class \code{character} indicating the measure
#' used for DOI computation, takes either \emph{gini}, \emph{hhi}, or
#' \emph{entropy}. Defaults to \emph{"gini"}.
#' @param locations Object of class \code{character} indicating for which
#' set of locations should be filtered. Defaults to \emph{"countries"}.
#'
#' @return Boxplot of DOI distribution as \code{ggplot2} object.
#'
#' @seealso
#' * \code{\link{export_doi}}
#' * \code{\link[ggplot2]{ggplot}}
#'
#' @examples
#' \dontrun{
#' data <- export_doi(
#'   object = 1,
#'   locations = "countries"
#' )
#' plot_doi_box(
#'   data_doi = data,
#'   type = "obs",
#'   measure = "gini"
#' )
#' plot_doi_box(
#'   data_doi = data,
#'   type = "sad",
#'   measure = "hhi"
#' )
#' plot_doi_box(
#'   data_doi = data,
#'   type = "trd",
#'   measure = "entropy"
#' )
#' }
#'
#' @export
#' @importFrom dplyr filter
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 geom_boxplot
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 labs
#' @importFrom glue glue
#' @importFrom rlang .data
#' @importFrom stringr str_to_upper

plot_doi_box <- function(data_doi, type = "obs", measure = "gini", locations = "countries") {
  if (!is.data.frame(data_doi)) stop(glue("Error: 'data_doi' must be object of type 'data.frame'.\nYou provided an object of type {typeof(data_doi)}."))
  .check_type(type)
  .check_measure(measure)
  .check_locations(locations)

  in_type <- type
  in_locations <- locations
  len_keywords <- length(unique(data_doi$keyword))
  if (len_keywords > 9) {
    warning(glue("The plot function is limited to 9 keywords in a boxplot.\nYou use {len_keywords} keywords.\nOnly the first 9 keywords are used."))
    data_doi <- filter(data_doi, .data$keyword %in% unique(data_doi$keyword)[1:9])
  }
  data_doi$measure <- data_doi[measure][[1]]
  data_doi <- filter(data_doi, .data$type == paste0("score_", in_type))
  data_doi <- filter(data_doi, .data$locations == in_locations)

  if (all(is.na(data_doi$measure))) {
    text <- glue("Plot cannot be created.\nThere is no non-missing data for score_{type}.")
    if (type != "obs") {
      text <- glue("{text}\nMaybe time series adjustments were impossible in compute_score due to less than 24 months of data.")
    }
    warning(text)
  } else {
    plot <- ggplot(data_doi, aes(x = .data$keyword, y = .data$measure)) +
      geom_boxplot() +
      labs(x = NULL, y = "Degree of internationalization", caption = glue("DOI computed as {str_to_upper(measure)}."))

    return(plot)
  }
}
