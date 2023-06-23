# function to repair elements of a Ra object that were not present in the file passed to read_ra()
# the functionality could also be placed in read_ra()
# as a prompt (like the one in the example) or as an argument repair=TRUE
repair_radecc <- function(Ra) {
  if(is.na(Ra$end.time)) Ra$end.time <- Ra$start.time + max(Ra$counts$Runtime)*60
  if(is.na(Ra$count.summary)) {
    Ra$count.summary <- data.frame(Runtime = max(Ra$counts$Runtime),
                                   CPM219 = mean(Ra$counts$CPM219),
                                   Cnt219 = sum(Ra$counts$Cnt219),
                                   CPM220 = mean(Ra$counts$CPM220),
                                   Cnt220 = sum(Ra$counts$Cnt220),
                                   CPMTot = mean(Ra$counts$CPMTot),
                                   CntTot = sum(Ra$counts$CntTot))
  }
  message(paste0("repaired Ra of file '",Ra$filename, "'"))
  warning("THIS FUNCTION IS UNDER DEVELOPMENT - DO NOT USE THE RESULTS")
  return(Ra)
}

# Ra <- read_ra("data/AL557/Count1/050621_1orange_St1.txt")
# if(is.na(Ra$count.summary)) {
#   p <- readline("repair x? (y/n) ")
#   if(p=="y") {
#     repair_radecc(Ra)
#   } else {
#     message("suit yourself")
#   }
# }