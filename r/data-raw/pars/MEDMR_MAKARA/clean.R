library(tidyverse)

dir <- "data-raw/pars/MEDMR_MAKARA"

metadata <- read_csv(file.path(dir, "raw/metadata.csv"), col_types = cols(.default = col_character()), na = c("N/A", "NA", "")) |> 
  filter(!is.na(monitoring_end_datetime)) |> 
  mutate(
    recording_device_code = coalesce(recording_device_code, "SOUNDTRAP"),
    recording_device_type_code = coalesce(recording_device_type_code, "SOUNDTRAP"),
    recording_device_depth_m = coalesce(recording_device_depth_m, "0"),
    recording_n_channels = coalesce(recording_n_channels, "1")
  )

detectiondata <- read_csv(file.path(dir, "raw/detectiondata.csv"), col_types = cols(.default = col_character()), na = c("N/A", "NA", "")) |> 
  filter(
    ymd_hms(detection_end_datetime) <= ymd_hms(analysis_end_datetime) + 86400
  )

detectiondata |> 
  left_join(metadata, by = c("deployment_code")) |> 
  mutate(
    across(ends_with("datetime"), ymd_hms)
  ) |> 
  filter(
    detection_end_datetime > analysis_end_datetime + 86400
  ) |> 
  select(
    deployment_code,
    ends_with("datetime")
  )

dir.create(file.path(dir, "clean"), showWarnings = FALSE)
write_csv(metadata, file.path(dir, "clean/metadata.csv"), na = "")
write_csv(detectiondata, file.path(dir, "clean/detectiondata.csv"), na = "")
