# calculate detector efficiencies
# Burts Efficiency Calc. 
calculate_efficiency <- function(Rn, # a list object produced by read_rn()
                                 dpm.223.std = 9.94,
                                 dpm.224.std = 12.1 
) {
  if(!grepl("standard$", Rn$type, ignore.case = TRUE)) {
    stop("the supplied data seems not to be from a standard")
  }
  
  CPM219 <- Rn$count.summary$CPM219
  CPM220 <- Rn$count.summary$CPM220
  CPMTot <- Rn$count.summary$CPMTot
  
  cc.219 <- ((CPMTot-CPM220-CPM219)^2*0.000093) / (1-((CPMTot-CPM220-CPM219)*0.000093))
  cc.220 <- ((CPMTot-CPM220-CPM219)^2*0.01) / (1-((CPMTot-CPM220-CPM219)*0.01))
  
  ## for isotope 223
  fr.220 <- (CPM220-cc.220)*0.0255 #  this is 219 fr.220 in excel
  corr.219 <- CPM219-cc.219-fr.220
  eff.219 <- corr.219/dpm.223.std
  
  ## for isotope 224
  fr.219 <- ((1.6*(CPM219-cc.219))^2*0.01) / ((1-(1.6*(CPM219-cc.219))*0.01))
  corr.220 <- CPM220-cc.220-fr.219
  eff.220 <- corr.220/dpm.224.std
  
  return( data.frame(filename = Rn$filename,
                     type = Rn$type,
                     isotope = as.numeric(sub("(223|224).*", "\\1", Rn$type)),
                     detector = Rn$detector,
                     eff.220 = eff.220,
                     eff.219 = eff.219) )
  
}
#calculate_efficiency(Rn = read_rn("data/AL557/Standards/050621_1orange_223Rastandard.txt"))
