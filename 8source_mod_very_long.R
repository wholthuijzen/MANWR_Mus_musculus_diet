# Install/load packages and files
if (!require(MixSIAR)) {
  warning("autoinstalling MixSIAR")
  library(devtools)
  remotes::install_github("brianstock/MixSIAR", dependencies=T, upgrade="never")
  library(MixSIAR)
}
mix.filename <- "mouse_consumer.csv"
source.filename <- "mouse_sources_raw.csv"
discr.filename <- "mouse_DTDF.csv"
options(max.print=5.5E5)

## Add "habitat" and "session" as a random effect
## Import consumer "mix" data
mix <- load_mix_data(filename="mouse_consumer.csv",
                     iso_names=c("d13C","d15N"),
                     factors= c("habitat", "session"),
                     fac_random= c(TRUE, TRUE),
                     fac_nested= c(FALSE, FALSE),
                     cont_effects=NULL)

### Import source data
source <- load_source_data(filename="mouse_sources_raw.csv",
                           source_factors=NULL,
                           conc_dep=TRUE,
                           data_type="raw",
                           mix)

### Import DTDF data
discr <- load_discr_data(filename="mouse_DTDF.csv", mix)


# Write the JAGS model file
model_filename <- "mod8habxses.txt"   # Name of the JAGS model file
resid_err <- TRUE
process_err <- TRUE
write_JAGS_model(model_filename, resid_err, process_err, mix, source)

jags.mod8habxses <- run_model(run="test", mix, source, discr, model_filename)

saveRDS(jags.mod8habxses, "jags.mod8habxses.Rds")