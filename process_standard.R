# load functions
sapply(list.files("functions/", full.names = T), source)

# find relevant files
files <- list.files("data/AL557/Standards/", full.names = TRUE)
types <- unlist(lapply(files, function(x) identify_type(x)))
standards <- files[which(grepl("standard$", types))]

# calculate efficiencies from standard measurements
eff <- data.frame()
for(std in standards) {
  eff <- rbind(eff,
               calculate_efficiency(read_rn(std)) )
}

# summarise results
eff <- merge(aggregate(eff.220~detector, data = eff[eff$isotope==224,], 
                       function(x) c(mean = mean(x), sd = sd(x), n = length(x))),
             aggregate(eff.219~detector, data = eff[eff$isotope==223,], 
                       function(x) c(mean = mean(x), sd = sd(x), n = length(x))))
eff <- do.call(data.frame, eff) # this because the result of each aggregate is a 3-column matrix that is placed into one column of the df, resulting in a df of 2 columns (after merging it's 3 cols)
colnames(eff) <- c("detector", "mean.eff.Rn224", "sd.eff.Rn224", "n.eff.Rn224", "mean.eff.Rn223", "sd.eff.Rn223", "n.eff.Rn223")

# check validity
if(any(eff$n.eff.Rn224<3 | eff$n.eff.Rn223<3)) {
  warning("some efficiencies have been calculated with less than 3 standard values")
  print(eff)
}

