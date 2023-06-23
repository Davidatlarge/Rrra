# calculate results
# the DMP values corrected for the ingrowth of decaying 228Th are the final concentration values of 224Ra and 224Ra
results_Ra <- function(count1, # the output of mutate_ra()
                       sampling.time, # as POSIX time
                       onFiber228Th, # numeric, preferably the output of onFiber_228Th()
                       estimate.227Ac = 0.05 # a constant, will be subtracted from 219 concentration before dividing that by the decay factor
) {
  if(is.na(count1$midpoint)) stop("The midpoint of count1 is NA, cannot calculate results.")
  if(sampling.time>count1$midpoint) stop("sampling.time must be earlier than the midpoint of count1")
  
  # calculate final 220
  decay.factor224 <- decay_factor(halflife = 3.66, midpoint = count1$midpoint, sampling.time = sampling.time) # 3.66 is the half life of 224Ra in days
  dpm.220per100L.decay.corrected <- (count1$dpm.220per100L-onFiber228Th) / decay.factor224 # quite different from excel, small errors compound here; could be due to differences in eff and/or blk
  err.dpm.220per100L.decay.corrected <- (count1$err.dpm.220per100L/count1$dpm.220per100L) * dpm.220per100L.decay.corrected
  
  # calculate final 219
  decay.factor223 <- decay_factor(halflife = 11.434, midpoint = count1$midpoint, sampling.time = sampling.time) # 11.434 is the half life of 223Ra in days
  dpm.219per100L.decay.corrected <- (count1$dpm.219per100L-estimate.227Ac) / decay.factor223
  err.dpm.219per100L.decay.corrected <- (count1$err.dpm.219per100L/count1$dpm.219per100L) * dpm.219per100L.decay.corrected
  
  return(data.frame(Ra224.DPMper100L = dpm.220per100L.decay.corrected,
                    err.Ra224.DPMper100L = err.dpm.220per100L.decay.corrected,
                    Ra223.DPMper100L = dpm.219per100L.decay.corrected,
                    err.Ra223.DPMper100L = err.dpm.219per100L.decay.corrected))
}

