# calcualte 228Th on fiber
onFiber_228Th <- function(midpoint.1,
                          midpoint.2,
                          dpm.220per100L.1,
                          dpm.220per100L.2,
                          sampling.time,
                          error.out = FALSE # if true, the output is the error
) {
  decay.constant.224Ra <- log(2)/3.66 # 3.66 is 224Ra half life - why do you use the half life of 224Ra when calculating ingrowth of 228Th?
  
  elapsed <- as.numeric(midpoint.2-midpoint.1)
  out <- (dpm.220per100L.1 - (dpm.220per100L.2 * exp(decay.constant.224Ra*elapsed))) / (1-exp(decay.constant.224Ra*elapsed))
  
  if(error.out) {
    decay.factor <- exp(-log(2) / 3.66 * as.numeric(midpoint-sampling.time))
    out <- out / decay.factor
  } 
  
  return(out)
}
# # lazy example....
# onFiber_228Th(midpoint.1 = c1$midpoint, 
#               midpoint.2 = c2$midpoint, 
#               dpm.220per100L.1 = c1$dpm.220per100L,
#               dpm.220per100L.2 = c2$dpm.220per100L)

