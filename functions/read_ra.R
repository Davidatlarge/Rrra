# function to read .txt files that contain output of Ra analysis
read_ra <- function(file, # a RaDeCC output file
                    detectors, # quoted possible names of detectors in the file name
                    date.format, # the strptime style format of ONLY the DATE part of Start Time in the 2nd line of the RaDeCC .txt file 
                    repair = FALSE # should the count summary and the Stop Time be repaired if they are missing from the file?
) {
  # read file by lines
  filelines <- readLines(file)
  
  # extract the original file name
  original.filename <- gsub(".*\\\\(.*)", "\\1", filelines[1])
  filename <- sub(".*[\\\\|/]", "", file)
  
  # extract sample id
  id <- sub(".*(St[^_|.txt]*).*", "\\1", file, ignore.case = TRUE)
  
  # extract detector from file name
  detector <- paste(detectors, collapse = "|")
  detector <- sub(paste0(".*(",detector,").*"), "\\1", file)
  if(!(detector %in% detectors)
  ) {
    detector <- NA
    warning(paste0("Detector not found in ", filename, ". Returning NA.\n Have you supplied the correct potential detector name?"))
  }
  
  # extract raw count data
  if(any(grep("Runtime", filelines)) & 
     length(filelines)>grep("Runtime", filelines)[1] # to see that there is at least one row after the header
  ) {
    startline <- grep("Runtime", filelines)[1]
    if(any(grep("Stopped", filelines))) { # if the run was properly stopped
      endline <- grep("Stopped", filelines)[1]-1 # last raw data row is above the line containing "Stopped"
    } else {
      endline <- length(filelines) # else, last raw data row is the last row
    }
    countlines <- filelines[startline:endline]
    countlines <- countlines[!grepl("\"", countlines)]
    counts <- unlist(strsplit(countlines, split = " +"))
    counts <- as.data.frame(matrix(counts, nrow = length(countlines), byrow = TRUE))
    colnames(counts) <- counts[1,]
    counts <- counts[-1,]
    counts <- as.data.frame(apply(counts, MARGIN = 2, FUN = function(x) as.numeric(x)))
  } else {
    counts <- NA
    warning(paste0("No counts available in ", file,". Returning NA"))
  }
  
  # extract Count Summary
  if(any(grepl("Count Summary", filelines))) {
    count.summary <- filelines[grep("Count Summary", filelines)+c(2,3)]
    count.summary <- as.data.frame(t(data.frame(row.names = unlist(strsplit(count.summary[1], split = " +")),
                                                value = as.numeric(unlist(strsplit(count.summary[2], split = " +"))))))
    rownames(count.summary) <- NULL
  } else {
    if(repair) {
      count.summary <- data.frame(Runtime = max(counts$Runtime),
                                  CPM219 = mean(counts$CPM219),
                                  Cnt219 = sum(counts$Cnt219),
                                  CPM220 = mean(counts$CPM220),
                                  Cnt220 = sum(counts$Cnt220),
                                  CPMTot = mean(counts$CPMTot),
                                  CntTot = sum(counts$CntTot))
      message(paste0("repaired Summary in Ra of file '", filename, "'"))
      warning("REPAIR FUNCIONALITY IS UNDER DEVELOPMENT - use results with caution")
    } else {
      count.summary <- NA
      warning(paste0("Count Summary not available in ", file,". Returning NA"))
    }
    
  }
  
  # extract start time
  start.time <- grep("Start Time", filelines, value = TRUE)
  start.time <- sub("Start Time ", "", start.time)
  start.time <- gsub(" +", "T", start.time)
  start.time <- as.POSIXct(start.time, format = paste0(date.format,"T%H:%M:%S"))
  if(is.na(start.time)
  ) {
    warning(paste0("Could not find Start Time in the provided date format. Returning NA.\n The supplied format is '", date.format, "'. In the file it is '", grep("Start Time", filelines, value = TRUE),"'."))
  }
  
  # extract stop time
  if(any(grepl("Stopped", filelines))
  ) {
    end.time <- grep("Stopped", filelines, value = TRUE)
    end.time <- sub(".*Stopped ", "", end.time)
    end.time <- gsub(" +", "T", end.time)
    end.time <- as.POSIXct(end.time, format = paste0(date.format,"T%H:%M:%S"))
    if(is.na(end.time)) warning(paste0("Could not find Stop Time in the provided date format. Returning NA.\n The supplied format is '", date.format, "'. In the file it is '", grep("Stopped", filelines, value = TRUE),"'."))
  } else {
    if(repair) {
      end.time <- start.time + max(counts$Runtime)*60
      message(paste0("repaired Stop Time in Ra of file '", filename, "'"))
      warning("REPAIR FUNCIONALITY IS UNDER DEVELOPMENT - use results with caution")
    } else {
      end.time <- NA
      warning(paste0("Stop Time not available in file:", file,". Returning NA."))
    }
  }
  
  # return result
  return(list(filename = filename,
              original.filename = original.filename,
              id = id,
              detector = detector,
              start.time = start.time,
              end.time = end.time,
              count.summary = count.summary,
              counts = counts))
  
}

# read_ra(file = "data/test_case1/050621_1grey_St3.txt", detectors = c("orange","blue","grey","green"), date.format = "%m/%d/%Y")
# read_ra("data/AL557/Count1/050621_1orange_St1.txt", repair = T)