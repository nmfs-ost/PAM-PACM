library(tidyverse)

dir <- "data-raw/pars/JASCO_20261008"

detectiondata <- read_csv(file.path(dir, "raw/detectiondata_JASCO.csv"), col_types = cols(.default = col_character()), na = c("N/A", "NA", "")) |> 
  filter(!submission_id %in% c("JASCO_20220819"))

detectiondata |>
  tabyl(submission_id)
detectiondata |> 
  tabyl(analysis_detector_code)
detectiondata |>
  distinct(submission_id, analysis_organization_code, deployment_code) |> 
  arrange(submission_id, analysis_organization_code, deployment_code)

pars_detectiondata <- tar_read(pars_detectiondata) |> 
  distinct(submission_id, analysis_organization_code, deployment_code, analysis_sound_source_codes)

# all detectiondata analyses exist in current pars dataset
detectiondata |> 
  distinct(submission_id, analysis_organization_code, deployment_code, analysis_sound_source_codes) |>
  anti_join(pars_detectiondata, by = c("submission_id", "analysis_organization_code", "deployment_code", "analysis_sound_source_codes"))

# make sure detectiondata includes all deployments from old submission
pars_detectiondata |> 
  filter(submission_id %in% unique(detectiondata$submission_id)) |> 
  anti_join(detectiondata, by = c("submission_id", "analysis_organization_code", "deployment_code", "analysis_sound_source_codes"))

# list submissions to remove detection data for
detectiondata |> 
  distinct(submission_id)

dir.create(file.path(dir, "clean"), showWarnings = FALSE)
detectiondata |> 
  select(-submission_id) |> 
  mutate(
    detection_n_validated = if_else(detection_result_code %in% c("DETECTED", "POSSIBLY_DETECTED"), coalesce(detection_n_validated, "0"), detection_n_validated)
  ) |> 
  write_csv(file.path(dir, "clean/detectiondata.csv"), na = "")
