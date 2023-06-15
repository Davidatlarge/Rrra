# calculate 228Th on fiber
onFiber_228Th <- function(midpoint.1,
                          midpoint.2,
                          dpm.220per100L.1,
                          dpm.220per100L.2,
                          sampling.time,
                          error.out = FALSE # if true, the output is the error
) {
  if(midpoint.1>midpoint.2) stop("midpoint.1 must be earlier than midpoint.2")
  
  decay.constant.224Ra <- log(2)/3.66 # 3.66 is 224Ra half life
  
  elapsed <- as.numeric( difftime(midpoint.2, midpoint.1, units = "days") )
  
  out <- (dpm.220per100L.1 - (dpm.220per100L.2 * exp(decay.constant.224Ra*elapsed))) / (1-exp(decay.constant.224Ra*elapsed))
  
  if(error.out) {
    if(sampling.time>midpoint.2) stop("sampling.time must be earlier than midpoint.2")
    decay.factor.224 <- exp(-log(2) / 3.66 * as.numeric(midpoint.2-sampling.time))
    out <- out / decay.factor.224
  } 
  
  return(out)
}
# # lazy example....
# onFiber_228Th(midpoint.1 = c1$midpoint, 
#               midpoint.2 = c2$midpoint, 
#               dpm.220per100L.1 = c1$dpm.220per100L,
#               dpm.220per100L.2 = c2$dpm.220per100L)

