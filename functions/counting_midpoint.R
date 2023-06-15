counting_midpoint <- function(start.time, # As POSIXct
                              Runtime # in minutes
) {
  # adding the run time minutes to the start time
  return(start.time + (Runtime*60)) # R adds numbers as seconds, so x60 for minutes
}

#calculate_midpoint(as.POSIXct("2021/06/05 10:42:00"), 40.4)
