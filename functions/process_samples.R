# process samples - change function name
# This function processes all samples in a folder 
# It returns the output of results_ra() for each sample, provided there are 2 counts for the sample
# Alternatively for all samples and all counts, i.e. all individual RaDeCC measurements, 
# the output of mutate_ra() can be returned

process_samples <- function(files, # files = "data/test_case1/"
                            blk,
                            eff,
                            meta, # depending on meta data input way, this can be removed
                            sample.id.pattern, # this could/should be changed; the sample identification is an importnat issue
                            halfway = FALSE # change argument name
) {
  # source required functions
  sapply(list.files("functions/", full.names = T), source) # reduce this to what is actually needed
  
  # find samples - eventually look in the same folder as the blk and eff
  types <- unlist(lapply(files, function(x) identify_type(x)))
  samples <- files[which(grepl("sample$", types))]
  
  spl <- data.frame()
  for(sample in samples) {
    current <- read_ra(sample)
    sample.id <- sub(paste0(".*_(", sample.id.pattern, ").+"), 
                     "\\1", current$filename) # will change depending on sample identification
    sampling.time <- meta$sampling.time[meta$id==sample.id]
    volume <- meta$volume[meta$id==sample.id]
    
    # process the sample
    current <- process_ra(current)
    current <- mutate_ra(eff = eff, blk = blk, 
                         pro = current, 
                         filtration_volume_L = volume)
    # add metadata - depending on how metadata is supplied, this could be changed
    current$volume <- volume
    current$sampling.time <- sampling.time
    current$id <- sample.id
    
    spl <- rbind(spl, current)
  }
  
  ## return intermediate results if required
  if(halfway) { # change argment name
    return(spl)
    stop()
  }
  
  ## work with different counts for each sample
  spl <- split(spl, spl$id)
  
  res <- data.frame()
  for(i in 1:length(spl)) {
    # calculate 228Th on fiber
    # warning if n counts != 2; at the moment less than 2 should stop, more than 2 will be ignored
    current <- spl[[i]]
    current$count <- rank(current$start.time)
    current <- current[order(current$count),]
    onFiber228Th <- onFiber_228Th(midpoint.1 = current$midpoint[1], 
                                  midpoint.2 = current$midpoint[2], 
                                  dpm.220per100L.1 = current$dpm.220per100L[1],
                                  dpm.220per100L.2 = current$dpm.220per100L[2])
    
    # calculate the result
    result <- results_Ra(current[1,], current$sampling.time[1], onFiber228Th)
    result$id <- current$id[1]
    
    res <- rbind(res, result)
  }
  return(res)
}

# # example
# sapply(list.files("functions/", full.names = T), source)
# 
# files <- list.files("data/AL557/", recursive = TRUE, full.names = TRUE, pattern = ".txt$")
# blk <- summarise_blank(files)
# eff <- summarise_efficiency(files)
# 
# meta <- data.frame(id = c("St2", "St3"),
#                    sampling.time = as.POSIXct(c("2021-06-05 09:43:00", "2021-06-05 09:52:00")),
#                    volume = c(200.4, 200.5))
# samples <- list.files("data/test_case1/", pattern = ".txt$", full.names = TRUE)
# process_samples(files = samples,
#                 blk = blk, eff = eff, meta = meta,
#                 sample.id.pattern = "St[1-9]{1}", 
#                 halfway = FALSE)
