# Load packages and files
library(MixSIAR)
library(tidyverse)
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

### Make new folder for habitat and session model output

### Make an isospace plot
plot_data(filename="isospace_plot_mod8habxses_verylong", plot_save_pdf=TRUE, plot_save_png=FALSE, mix,source,discr)

### Calculate the convex hull area, standardized by source variance
calc_area(source=source,mix=mix,discr=discr)
# 14.52864

### Default "UNINFORMATIVE" / GENERALIST prior (alpha = 1)
plot_prior(alpha.prior=1,source, plot_save_pdf = TRUE, filename = "prior_plot")

### Plot Informed priors
alpha.spec <- c(0.121,0.360,1.625,0.833,3.758,1,0.166,0.138)
# rescale so sum(alpha) = n.sources
# alpha.spec <- alpha.spec*length(alpha.spec)/sum(alpha.spec)
plot_prior(alpha.prior=alpha.spec,
           source=source,
           filename="prior_plot_informed")

# Write the JAGS model file
model_filename <- "mod8habxses.txt"   # Name of the JAGS model file
resid_err <- TRUE
process_err <- TRUE
write_JAGS_model(model_filename, resid_err, process_err, mix, source)

jags.mod8habxses <- run_model(run="test", mix, source, discr, model_filename)

output_options <- list(summary_save = TRUE,
                       summary_name = "summary_statistics_mod8habxses",
                       sup_post = FALSE,
                       plot_post_save_pdf = TRUE,
                       plot_post_name = "posterior_density_mod8habxses",
                       sup_pairs = FALSE,
                       plot_pairs_save_pdf = TRUE,
                       plot_pairs_name = "pairs_plot_mod8habxses",
                       sup_xy = TRUE,
                       plot_xy_save_pdf = FALSE,
                       plot_xy_name = "xy_plot_mod8habxses",
                       gelman = TRUE,
                       heidel = FALSE,
                       geweke = TRUE,
                       diag_save = TRUE,
                       diag_name = "diagnostics_mod8habxses",
                       indiv_effect = FALSE,
                       plot_post_save_png = FALSE,
                       plot_pairs_save_png = FALSE,
                       plot_xy_save_png = FALSE,
                       diag_save_ggmcmc = FALSE,
                       return_obj = TRUE)

output_JAGS(jags.mod8habxses, mix, source, output_options)

par(mar = c(1, 1, 1, 1))
combine.mod8habxses <- combine_sources(jags.mod8habxses, mix, source, 
                                       groups=list(C3= "C3",
                                                   C4= "C4",
                                                   Albatross="LAYALB",
                                                   Arthropods= c("Araneae","Blattodea", "DIP-IXO-HYM-ISO", "Lepidoptera", "Megaselia scalaris")))
# Will also need to set new informed priors if running a model with informed priors for 8 sources

# get posterior medians for new source groupings
summary_stat(combine.mod8habxses, meanSD=TRUE, quantiles=c(.025,.05,.25,.5,.75,.95,.975), savetxt=TRUE)
plot_intervals(combine.mod8habxses, toplot="fac1", levels = NULL, groupby = "factor")
plot_intervals(combine.mod8habxses, toplot = "epsilon") # works
plot_intervals(combine.mod8habxses, toplot="fac2") # works 
plot_intervals(combine.mod8habxses, toplot="p") # works
plot_intervals(combine.mod8habxses, toplot="fac1") # doesn't work
plot_intervals(jags.mod8habxses, toplot = "fac1")

# Save R environment
save.image(file="myEnvironment_modhabxses8.RData")