counting_midpoint <- function(start.time, # As POSIXct
                              Runtime # in minutes
) {
  if(!inherits(start.time, "POSIXct")) {stop("start.time must be in POSIXct format")}
  
  # adding the run time minutes to the start time
  return(start.time + (Runtime*60)) # R adds numbers as seconds, so x60 for minutes
}

#counting_midpoint(as.Date("2021/06/05 10:42:00"), 40.4)
#counting_midpoint(as.POSIXct("2021/06/05 10:42:00"), 40.4)