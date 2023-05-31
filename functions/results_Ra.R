# calculate results
# the DMP values corrected for the ingrowth of decaying 228Th are the final concentration values of 224Ra and 224Ra
results_Ra <- function(count1, # the output of process_Ra() [once the outputs of final_Ra() are included, which I will do after 2023-05-31]
                       sampling.time,
                       onFiber228Th,
                       estimate.227Ac = 0.05 # a constant, will be subtracted from 219 concentration before dividing that by the decay factor
) {
  # calculate final 220
  decay.factor224 <- exp(-log(2) / 3.66 * as.numeric(count1$midpoint-sampling.time) ) # 3.66 is the half life of 224Ra in days
  dpm.220per100L.decay.corrected <- (count1$dpm.220per100L-onFiber228Th) / decay.factor224 # quite different from excel, small errors compound here; could be due to differences in eff and/or blk
  err.dpm.220per100L.decay.corrected <- (count1$err.dpm.220per100L/count1$dpm.220per100L) * dpm.220per100L.decay.corrected
  
  # calculate final 219
  decay.factor223 <- exp(-log(2) / 11.434 * as.numeric(count1$midpoint-sampling.time) ) # 11.434 is the half life of 223Ra in days
  dpm.219per100L.decay.corrected <- (count1$dpm.219per100L-estimate.227Ac) / decay.factor223
  err.dpm.219per100L.decay.corrected <- (count1$err.dpm.219per100L/count1$dpm.219per100L) * dpm.219per100L.decay.corrected
  
  return(data.frame(Ra224.DPMper100L = dpm.220per100L.decay.corrected,
                    err.Ra224.DPMper100L = err.dpm.220per100L.decay.corrected,
                    Ra223.DPMper100L = dpm.219per100L.decay.corrected,
                    err.Ra223.DPMper100L = err.dpm.219per100L.decay.corrected))
}

