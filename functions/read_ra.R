# function to read .txt files that contain output of Ra analysis
read_ra <- function(file, # a RaDeCC output file
                    detectors = c("orange","blue","grey","green") # quoted possible names of detectors in the file name
) {
  
  # read file by lines
  filelines <- readLines(file)
  
  # extract the original file name
  original.filename <- gsub(".*\\\\(.*)", "\\1", filelines[1])
  filename <- sub(".*[\\\\|/]", "", file)
  
  # extract the measurement type
  source("functions/identify_type.R")
  type <- identify_type(file)
  
  # extract detector from file name
  detector <- sub(".*(orange|blue|grey|green).*", "\\1", file)
  if(!(detector %in% detectors)) {warning("detector not found")}
  
  # extract start time
  start.time <- filelines[grep("Start Time", filelines)]
  start.time <- sub("Start Time ", "", start.time)
  start.time <- gsub(" +", "T", start.time)
  start.time <- as.POSIXct(start.time, format = "%m/%d/%YT%H:%M:%S")
  
  # extract stop time
  if(any(grepl("Stopped", filelines))) {
    end.time <- filelines[grep("Stopped", filelines)]
    end.time <- sub(".*Stopped ", "", end.time)
    end.time <- gsub(" +", "T", end.time)
    end.time <- as.POSIXct(end.time, format = "%m/%d/%YT%H:%M:%S")
  } else {
    end.time <- NA
    warning(paste0("Stop Time not available in ", file,". Returning NA"))
  }
  
  # extract Count Summary
  if(any(grepl("Count Summary", filelines))) {
    count.summary <- filelines[grep("Count Summary", filelines)+c(2,3)]
    count.summary <- as.data.frame(t(data.frame(row.names = unlist(strsplit(count.summary[1], split = " +")),
                                                value = as.numeric(unlist(strsplit(count.summary[2], split = " +"))))))
  } else {
    count.summary <- NA
    warning(paste0("Count Summary not available in ", file,". Returning NA"))
  }
  
  # extract raw count data
  if(any(grep("Runtime", filelines)) & 
     length(filelines)>grep("Runtime", filelines)[1]) {
    startline <- grep("Runtime", filelines)[1]
    if(!is.na(end.time)) {
      endline <- grep("Stopped", filelines)[1]-1
    } else {
      endline <- length(filelines)
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
  
  # return result
  return(list(filename = filename,
              original.filename = original.filename,
              type = type,
              detector = detector,
              start.time = start.time,
              end.time = end.time,
              count.summary = count.summary,
              counts = counts))
  
}

#read_ra(file = "data/AL557/Count1/050621_1grey_St10_blank.txt")
