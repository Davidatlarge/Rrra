decay_factor <- function(isotope, # c(223,224)
                         midpoint, # calculated with calculate_midpoint()
                         sampling.time # as POCIXct with date and time
) {
  hl <- data.frame(iso = c(223, 224),
                   hl = c(11.434, 3.66))
  return(exp(-log(2) / hl$hl[hl$iso==isotope] * as.numeric(midpoint-sampling.time) ))
}

#decay_factor(11.434, )