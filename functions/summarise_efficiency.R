# summarise results of standard measurements in a list of files
# standards are identified from the path/file name, calling identify_type(),
# so other measurement files can be listed but will be ignored.
# calls read_rn() and calculate_efficiency()) and applies it to the listed files
# filters the results so that only 220 efficiency is used with Rn224 and 219 efficiency with Rn223
# then aggregates the results (unless summarise ==FALSE)
# it is possible to supply only one file name 
summarise_efficiency <- function(files,
                                 summarise = TRUE # should the results of all files be summarised, if FALSE returns a table of individual efficiencies
) {
  # load functions
  source("functions/identify_type.R")
  source("functions/calculate_efficiency.R")
  source("functions/read_rn.R")
  
  # find relevant files
  types <- unlist(lapply(files, function(x) identify_type(x)))
  standards <- files[which(grepl("standard$", types))]
  if(length(standards)<1) {stop("no standards indentified in input files")}
  
  # calculate efficiencies from standard measurements
  eff <- data.frame()
  for(std in standards) {
    eff <- rbind(eff,
                 calculate_efficiency(read_rn(std)) )
  }
  
  if(summarise) {
    # summarise results
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
