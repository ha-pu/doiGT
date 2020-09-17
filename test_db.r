# run data base test

# packages ----
library(doiGT)
library(tidyverse)
options(dplyr.summarise.inform = FALSE)

# connect to db ----
dir_current <- getwd()
dir_wd <- tempdir()
setwd(dir_wd)
initialize_db()
start_db()

# add new control batch ----
new_control <- add_control_keyword(keyword = c("gmail", "wikipedia"), time = "2016-01-01 2019-12-31")
filter(batch_keywords, batch == new_control & type == "control")

# add new object batch ----
new_object <- add_object_keyword(keyword = c("manchester united", "real madrid"), time = "2016-01-01 2019-12-31")
filter(batch_keywords, batch == new_object & type == "object")

# run control download ----
download_control(control = new_control, locations = countries[1:5])
download_control(control = new_control, locations = us_states[1:5])
filter(data_control, batch == new_control)

# run object download ----
download_object(object = new_object, locations = countries[1:5])
download_object(object = new_object, locations = us_states[1:5])
filter(data_object, batch == new_object)

# run map download ----
download_mapping(control = new_control, object = new_object, locations = countries)
download_mapping(control = new_control, object = new_object, locations = us_states)
filter(data_mapping, batch_c == new_control & batch_o == new_object)

# run scoring ----
compute_score(control = new_control, object = new_object, locations = countries)
compute_score(control = new_control, object = new_object, locations = us_states)
filter(data_score, batch_c == new_control & batch_o == new_object)

# run aggregation ----
compute_doi(control = new_control, object = new_object, locations = "countries")
compute_doi(control = new_control, object = new_object, locations = "us_states")
filter(data_doi, batch_c == new_control & batch_o == new_object)

# run world download ----
download_global(object = new_object)
filter(data_global, batch == new_object)

# export data ----
export_control(control = 1)
export_object(keyword = "manchester united")
export_global(type = "sad")
export_mapping(control = 1, object = 1)
export_score(keyword = "manchester united")
export_doi(control = 1, object = 1, type = "trd", locations = "us_states")

# plot data ----
export_doi(type = "obs", locations = "countries") %>%
  plot_ts(grid = TRUE, smooth = TRUE)

export_doi() %>%
  plot_ts(type = "obs", locations = "countries", grid = TRUE, smooth = TRUE)

export_doi(type = "obs", locations = "countries") %>%
  plot_ts(grid = FALSE, smooth = FALSE)

export_doi(type = "sad", locations = "us_states") %>%
  plot_box()

export_doi() %>%
  plot_box(type = "sad", locations = "us_states")

data1 <- export_doi(keyword = "manchester united", locations = "countries")
data2 <- export_global(keyword = "manchester united")

plot_trend(data_doi = data1, data_global = data2, type = "obs", measure = "gini", smooth = TRUE)
plot_trend(data_doi = data1, data_global = data2, type = "sad", measure = "hhi", smooth = FALSE)
plot_trend(data_doi = data1, data_global = data2, type = "trd", measure = "entropy", smooth = TRUE)

export_score(keyword = "manchester united") %>%
  filter(location %in% countries) %>%
  plot_score(type = "sad")

# remove data ----
remove_data(table = "batch_keywords", control = new_control)
remove_data(table = "batch_keywords", object = new_object)

filter(batch_keywords, batch == new_control & type == "control")
filter(batch_keywords, batch == new_object & type == "object")
filter(data_control, batch == new_control)
filter(data_object, batch == new_object)
filter(data_mapping, batch_c == new_control & batch_o == new_object)
filter(data_score, batch_c == new_control & batch_o == new_object)
filter(data_global, batch == new_object)

# disconnect from db ----
disconnect_db()
