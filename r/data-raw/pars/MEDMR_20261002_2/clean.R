library(tidyverse)

dir <- "data-raw/pars/MEDMR_20261002_2"

metadata <- read_csv(file.path(dir, "raw/metadata.csv"), col_types = cols(.default = col_character()), na = c("N/A", "NA", "")) |> 
  filter(!is.na(monitoring_end_datetime))

dir.create(file.path(dir, "clean"), showWarnings = FALSE)
write_csv(metadata, file.path(dir, "clean/metadata.csv"), na = "")
file.copy(file.path(dir, "raw/detectiondata.csv"), file.path(dir, "clean/detectiondata.csv"), overwrite = TRUE)
