# calculate detector efficiencies
# Burts Efficiency Calc. 
calculate_efficiency <- function(Ra, # a list object produced by read_ra()
                                 dpm.223.std = 9.94, # Personal Comm Walter Geibert (AWI)
                                 dpm.224.std = 12.1 # Personal Comm Walter Geibert (AWI)
) {
  if(!grepl("standard$", Ra$type, ignore.case = TRUE)) {
    stop("the supplied data seems not to be from a standard")
  }
  
  if(all(!is.na(Ra$count.summary))) {
    CPM219 <- Ra$count.summary$CPM219
    CPM220 <- Ra$count.summary$CPM220
    CPMTot <- Ra$count.summary$CPMTot
    
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
    
    return( data.frame(filename = Ra$filename,
                       type = Ra$type,
                       isotope = as.numeric(sub("(223|224).*", "\\1", Ra$type)),
                       detector = Ra$detector,
                       eff.220 = eff.220,
                       eff.219 = eff.219) )
  } else {
    warning(paste0("no valid summary in standard of file '", Ra$filename, "', ignoring file"))
  }
}
#calculate_efficiency(Ra = read_ra("data/AL557/Standards/050621_1orange_223Rastandard.txt"))
