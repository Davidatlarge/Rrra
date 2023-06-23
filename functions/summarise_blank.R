# summarise results of blank measurements in a list of files
# blanks are identified from the path/file name, calling identify_type(),
# so other measurement files can be listed but will be ignored.
# calls read_ra() and applies it to the listed files
# then aggregates the results (unless summarise ==FALSE)
# assigns the results so that only 220 counts are used with Ra224 and 219 counts with Ra223
# it is possible to supply only one file name 
summarise_blank <- function(files,
                            blank.id, # string to identify blanks in the file name
                            summarise = TRUE # should the results of all files be summarised, if FALSE returns a table of individual blanks
) {
  types <- unlist(lapply(files, function(x) identify_type(x, blank.id = blank.id)))
  blanks <- files[which(grepl("blank$", types))]
  if(length(blanks)<1) {stop("no blanks indentified in input files")}
  
  # extract values from blank measurement results
  blk <- data.frame()
  for(blank in blanks) {
    current <- read_ra(blank)
    if(all(!is.na(current$count.summary))) {
      blk <- rbind(blk,
                   data.frame(file = sub(".*[\\\\|/]", "", blank),
                              detector = current$detector,
                              CMP219 = current$count.summary$CPM219,
                              CMP220 = current$count.summary$CPM220,
                              CMPTot = current$count.summary$CPMTot))
    } else {
      warning(paste0("no valid summary in blank of file '", current$filename, "', ignoring file"))
    }
  }
  
  # summarise results
  if(summarise) {
    blk <- reshape(blk, 
                   direction = "long", # turn to long table for aggregating
                   v.names = "value", 
                   varying = names(blk)[3:5], 
                   idvar = names(blk)[1:2], 
                   timevar = "b",
                   time = names(blk)[3:5])
    blk <- aggregate(value~detector+b, data = blk, 
                     function(x) c(mean = mean(x), sd = sd(x), n = length(x)))
    blk <- do.call(data.frame, blk) # because the result of each aggregate is a 3-column matrix that is placed into one column of the df, resulting in a df of 2 columns (after merging it's 3 cols)
    colnames(blk) <- c("detector", "isotope", "mean", "sd", "n")
    blk$isotope[blk$isotope=="CMP219"] <- 223
    blk$isotope[blk$isotope=="CMP220"] <- 224
    
    # check validity
    if(any(blk$n<3)) {
      message("some blank summaries have been calculated with fewer than 3 values")
    }
  }
  
  return(blk)
}

# summarise_blank(files = list.files("data/AL557/Count1/", full.names = TRUE))
