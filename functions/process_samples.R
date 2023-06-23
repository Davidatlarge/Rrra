# process samples - change function name
# This function processes all samples in a folder 
# It returns the output of results_ra() for each sample, provided there are 2 counts for the sample
# Alternatively for all samples and all counts, i.e. all individual RaDeCC measurements, 
# the output of mutate_ra() can be returned

process_samples <- function(files, # files = "data/test_case1/"
                            blk,
                            eff,
                            blank.id = "blank", # is is for identify type to inherit, but it is a bit clumsy seeing that the strings were already given to summarise.blank() and summarise.efficiency()
                            standard.id = "standard|std",
                            meta, # depending on meta data input way, this can be removed
                            halfway = FALSE, # change argument name
                            verbose = TRUE
) {
  # check if input is correct
  if(any(!grepl("id|sampling.time|volume", colnames(meta))) |
     !inherits(meta$id, "character") | 
     !inherits(meta$sampling.time, "POSIXct") |
     !inherits(meta$volume, "numeric") 
  ) {
    stop("'meta' must have columns 'id' as character, 'sampling.time' as POSIXct and, 'volume' as numeric (in liters)")
  }
  
  # find samples
  types <- unlist(lapply(files, function(x) identify_type(x, blank.id = blank.id, standard.id = standard.id)))
  samples <- files[which(grepl("sample$", types))]
  if(length(samples)<1) {stop("no samples indentified in input files")}
  
  # process and mutate all samples
  spl <- data.frame()
  for(sample in samples) {
    current <- read_ra(sample)
    sample.id <- sub(".*(St[^_|.txt]*).*", "\\1", current$filename, ignore.case = TRUE)
    if(verbose) {
      message(paste0("identified sample '", sample.id, "' in file '", current$filename, "'"))
    }
    if(sum(meta$id==sample.id)==1) {
      if(verbose) {
        message(paste0("matching sample '", sample.id, "' with meta data id '", meta$id[meta$id== sample.id], "', with sampling time '", meta$sampling.time[meta$id== sample.id], "' and filtration volume ", meta$volume[meta$id==sample.id], " L"))
      }
      sampling.time <- meta$sampling.time[meta$id==sample.id]
      volume <- meta$volume[meta$id==sample.id]
      
      # process the sample
      current <- process_ra(current)
      current <- mutate_ra(eff = eff, blk = blk, 
                           pro = current, 
                           filtration_volume_L = volume)
      # add metadata
      current$volume <- volume
      current$sampling.time <- sampling.time
      current$id <- sample.id
      
      spl <- rbind(spl, current)
    } else {
      warning(paste0("no unique sample with id '", sample.id, "' found in meta. Skipping file '", current$filename, "'"))
    }
  }
  
  ## return intermediate results if required
  if(halfway) { # change argument name
    return(spl)
    stop()
  }
  
  ## work with different counts for each sample
  spl <- split(spl, spl$id)
  
  res <- data.frame()
  for(i in 1:length(spl)) {
    current <- spl[[i]]
    if(nrow(current)<2) {
      warning(paste0("less than 2 counts for sample id '", current$id[1], "', skipping file '", current$file[1], "'"))
    } else {
      # calculate 228Th on fiber
      current$count <- rank(current$start.time)
      current <- current[order(current$count),]
      current <- current[order(current$count),]
      if(verbose) { # print the times for each measurement to check if they make sense
        message(paste0("in sample '", current$id[1], "'"))
        message(paste0(capture.output(current[c("count", "sampling.time", "midpoint", "file")]), collapse = "\n"))
        if(nrow(current)>2) {
          message(paste0("more than 2 counts for sample id '", current$id[1], "', skipping file/s '", paste(current$file[3:nrow(current)], collapse="', '"), "'"))
        }
      }
      onFiber228Th <- onFiber_228Th(midpoint.1 = current$midpoint[1],
                                    midpoint.2 = current$midpoint[2],
                                    dpm.220per100L.1 = current$dpm.220per100L[1],
                                    dpm.220per100L.2 = current$dpm.220per100L[2])
      
      # calculate the result
      result <- results_Ra(current[1,], current$sampling.time[1], onFiber228Th)
      result$id <- current$id[1]
      
      res <- rbind(res, result)
    }
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
