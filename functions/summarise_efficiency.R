# summarise results of standard measurements in a list of files
# standards are identified from the path/file name, calling identify_type(),
# so other measurement files can be listed but will be ignored.
# calls read_ra() and calculate_efficiency()) and applies it to the listed files
# filters the results so that only 220 efficiency is used with Rn224 and 219 efficiency with Rn223
# then aggregates the results (unless summarise ==FALSE)
# it is possible to supply only one file name 
summarise_efficiency <- function(files,
                                 standard.id = "standard|std", # string to identify standards in the file name
                                 blank.id = "blank",
                                 dpm.223.std = 9.94, # Personal Comm Walter Geibert (AWI)
                                 dpm.224.std = 12.1, # Personal Comm Walter Geibert (AWI)
                                 summarise = TRUE # should the results of all files be summarised, if FALSE returns a table of individual efficiencies
) {
  # find relevant files
  types <- unlist(lapply(files, function(x) identify_type(x, standard.id = standard.id, blank.id = blank.id)))
  standards <- files[which(grepl("standard$", types))]
  if(length(standards)<1) {stop("no standards indentified in input files")}
  
  # calculate efficiencies from standard measurements
  eff <- data.frame()
  for(std in standards) {
    Ra <- read_ra(std)
    type <- identify_type(std, standard.id = standard.id, blank.id = blank.id)
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
    
    eff <- rbind(eff, data.frame(filename = Ra$filename,
                                 type = type,
                                 isotope = as.numeric(sub("(223|224).*", "\\1", type)),
                                 detector = Ra$detector,
                                 eff.220 = eff.220,
                                 eff.219 = eff.219))
  }
  
  # summarise results
  if(summarise) {
    eff <- reshape(eff, direction = "long", # turn to long table for aggregating
                   v.names = "value", 
                   varying = names(eff)[5:6], 
                   idvar = names(eff)[1:4], 
                   timevar = "e",
                   time = names(eff)[5:6])
    eff <- eff[eff$isotope==223 & eff$e=="eff.219" | eff$isotope==224 & eff$e=="eff.220",]
    eff <- aggregate(value~detector+isotope, data = eff, 
                     function(x) c(mean = mean(x), sd = sd(x), n = length(x)))
    eff <- do.call(data.frame, eff) # because the result of each aggregate is a 3-column matrix that is placed into one column of the df, resulting in a df of 2 columns (after merging it's 3 cols)
    colnames(eff) <- c("detector", "isotope", "mean", "sd", "n")
    
    # check validity
    if(any(eff$n<3)) {
      message("some efficiencies have been calculated with fewer than 3 standard values")
    }
  }
  
  return(eff)
}

#summarise_efficiency(files = list.files("data/AL557/Standards/", full.names = TRUE))