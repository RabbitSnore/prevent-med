################################################################################

# Prevent-MED -- Power Calculations

################################################################################

# Load packages and set up environment -----------------------------------------

packages <- c(
  "dplyr",
  "tidyr",
  "ggplot2",
  "purrr",
  "lme4",
  "simr",
  "lmerTest",
  "foreach"
)

lapply(packages, library, character.only = TRUE)

# Set up data structure --------------------------------------------------------

# Design

condition   <- c("tau", "treat_ppdt", "treat_tpdt", "treat_epdt")
ns          <- c(60, 40, 40, 40) 
measurement <- c(0, 1, 6, 12)

# Structure

sim_str <- foreach(i = 1:length(condition), .combine = bind_rows) %do% {
  
  structure <- expand_grid(condition = condition[i], measurement)
  
  df <- map_dfr(seq_len(ns[i]), ~ structure)
  
  df$id <- paste(condition[i], sort(rep(1:ns[i], length(measurement))))
  
  df
  
}

sim_str$condition <- factor(sim_str$condition,
                            levels = c("tau", 
                                       "treat_ppdt", 
                                       "treat_tpdt", 
                                       "treat_epdt"))

sim_str <- sim_str %>% 
  mutate(
    degarelix = case_when(
      condition == "tau" ~ 0,
      condition == "treat_ppdt" | condition == "treat_tpdt" | condition == "treat_epdt"  ~ 1
    ),
    testosterone = case_when(
      condition == "tau" | condition == "treat_ppdt" | condition == "treat_epdt" ~ 0,
      condition == "treat_tpdt" ~ 1
    ),
    estradiol = case_when(
      condition == "tau" | condition == "treat_ppdt" | condition == "treat_tpdt" ~ 0,
      condition == "treat_epdt" ~ 1
    )
  )

# Power simulation -------------------------------------------------------------

# Primary outcome

## Fixed and random effects

fixed_design <- c(
   0.00, # intercept
  -0.50, # Measurement, change per month 
  -0.00, # PPDT, Placebo placebo, degarelix + TAU
  -0.00, # TPDT, Testosterone, placebo, degarelix + TAU
  -0.00, # EPDT, Placebo, Estradiol, degarelix + TAU
  -0.42, # PPDT x time, Placebo placebo, degarelix + TAU
  -0.10, # TPDT x time, Testosterone, placebo, degarelix + TAU
  -0.10  # EPDT x time, Placebo, Estradiol, degarelix + TAU
)

varcor_design <- list(
  15 # Based on preliminary data for a different treatment trial
)

sigma_design <- 4.00 # Conservative estimate based on preliminary data

## Simulated model

design_lmm <- makeLmer(
  formula  = 
  sotips 
  ~ 1 
  + measurement * degarelix
  + measurement * testosterone
  + measurement * estradiol
  + (1|id),
  fixef   = fixed_design,
  VarCorr = varcor_design,
  sigma   = sigma_design,
  data    = sim_str
)

## Simulation

if (!file.exists("./output/dgr-rct_power-sim.rds")) {
  
  # Simulation with relatively conservative effect estimates
  
  power_simulation <- powerSim(
    fit = design_lmm,
    test = fixed("measurement:degarelix", method = "t"),
    nsim = 1000,
    seed = 1124
  )
  
  saveRDS(power_simulation, "./output/dgr-rct_power-sim.rds")
  
} else {
  
  power_simulation <- readRDS("./output/dgr-rct_power-sim.rds")
  
}

## Dropout Rate 33%

### Simulated data set with reduced sample size

sim_str_33 <- foreach(i = 1:length(condition), .combine = bind_rows) %do% {
  
  structure <- expand_grid(condition = condition[i], measurement)
  
  df <- map_dfr(seq_len(round(ns[i] * .33)), ~ structure)
  
  df$id <- paste(condition[i], sort(rep(1:round(ns[i] * .33), length(measurement))))
  
  df
  
}

sim_str_33$condition <- factor(sim_str_33$condition,
                            levels = c("tau", 
                                       "treat_ppdt", 
                                       "treat_tpdt", 
                                       "treat_epdt"))

sim_str_33 <- sim_str_33 %>% 
  mutate(
    degarelix = case_when(
      condition == "tau" ~ 0,
      condition == "treat_ppdt" | condition == "treat_tpdt" | condition == "treat_epdt"  ~ 1
    ),
    testosterone = case_when(
      condition == "tau" | condition == "treat_ppdt" | condition == "treat_epdt" ~ 0,
      condition == "treat_tpdt" ~ 1
    ),
    estradiol = case_when(
      condition == "tau" | condition == "treat_ppdt" | condition == "treat_tpdt" ~ 0,
      condition == "treat_epdt" ~ 1
    )
  )


### Simulated model

design_lmm_33 <- makeLmer(
  formula  = 
    sotips 
  ~ 1 
  + measurement * degarelix
  + measurement * testosterone
  + measurement * estradiol
  + (1|id),
  fixef   = fixed_design,
  VarCorr = varcor_design,
  sigma   = sigma_design,
  data    = sim_str_33
)

### Simulation

if (!file.exists("./output/dgr-rct_power-sim-33.rds")) {
  
  power_simulation_33 <- powerSim(
    fit = design_lmm_33,
    test = fixed("measurement:degarelix", method = "t"),
    nsim = 1000,
    seed = 8989
  )
  
  saveRDS(power_simulation_33, "./output/dgr-rct_power-sim-33.rds")
  
} else {
  
  power_simulation_33 <- readRDS("./output/dgr-rct_power-sim-33.rds")
  
}
