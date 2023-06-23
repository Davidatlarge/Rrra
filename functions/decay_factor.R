decay_factor <- function(halflife, # 11.434 for 223Ra, 3.66 for 224Ra
                         midpoint, # calculated with calculate_midpoint()
                         sampling.time # as POSIXct with date and time
) {
  if(!inherits(sampling.time, "POSIXct") | !inherits(midpoint, "POSIXct")) {stop("mdipoint and sampling.time must be in POSIXct format")}
  
  return(exp(-log(2) / halflife * as.numeric(midpoint-sampling.time) ))
}

#decay_factor(11.434, )