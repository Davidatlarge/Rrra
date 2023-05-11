# takes an Rn object and outputs all parameters from Count 1 sheet that can be calculated from the Rn data alone

process_rn <- function(Rn # a list object produced by read_rn()
) {
  source("functions/counting_midpoint.R")
  
  # extract variables
  start.time <- Rn$start.time
  Runtime <- Rn$count.summary$Runtime
  CPMTot <- Rn$count.summary$CPMTot
  CPM220 <- Rn$count.summary$CPM220
  CPM219 <- Rn$count.summary$CPM219
  
  ## process sample
  midpoint <- counting_midpoint(start.time = start.time, Runtime = Runtime) # hard to compare with excel cos of different formats
  
  # ERR Total CPM
  total.counts <- Runtime * CPMTot
  err.total.cpm <- sqrt(total.counts) / Runtime
  
  # Background
  cc.220 <- ((CPMTot-CPM220-CPM219)^2*0.01) / ((1-((CPMTot-CPM220-CPM219)*0.01)))
  cc.219 <- ((CPMTot-CPM220-cc.220-CPM219)^2*0.000093) / ((1-(CPMTot-CPM220-cc.220-CPM219)*0.000093))
  
  # Err 220 CPM
  counts.220 <- Runtime * CPM220
  err.220.cpm <- sqrt(counts.220) / Runtime
  err.220.2by <- 2/sqrt(counts.220)
  err.220 <- sqrt(counts.220-(cc.220*Runtime)) / (counts.220-(cc.220*Runtime))
  
  # Err 219 CPM
  counts.219 <- Runtime * CPM219
  err.219.cpm <- sqrt(counts.219) / Runtime
  err.219.2by <- 2/sqrt(counts.219)
  err.219 <- sqrt((CPM219*total.counts)-(cc.219*total.counts))/((CPM219*total.counts)-(cc.219*total.counts))
  
  # Background (cont.)
  x <- CPMTot-CPM220-CPM219
  err.x <- sqrt((err.total.cpm^2)+(err.220.cpm^2)+(err.219.cpm^2))
  err.cc.220 <- err.x*(((2*0.01*x)-(0.01*x)^2)/(1-0.01*x)^2)
  err.corr.220 <- sqrt((err.220.cpm^2)+(err.cc.220^2)) #  this belongs in the Corrections group but is needed before
  err.y <- sqrt((err.219.cpm^2)+(err.corr.220^2)+(err.total.cpm^2))
  err.cc.219 <- err.y*(((2*0.000093*x-(0.01*x))^2)/(1-(0.000093*x)^2))
  
  # Corrections
  corr.220 <- CPM220-cc.220
  corr.219 <- CPM219-cc.219
  err.corr.219 <- sqrt((err.219.cpm^2)+(err.cc.219^2))
  y <- CPMTot-corr.220-CPM219
  
  return(data.frame(file = sub(".*[\\\\|/]", "", Rn$filename),
                    detector = Rn$detector,
                    start.time = start.time,
                    Runtime = Runtime,
                    midpoint = midpoint,
                    CPMTot = CPMTot,
                    CPM219 = CPM219,
                    CPM220 = CPM220,
                    err.total.cpm = err.total.cpm,
                    total.counts = total.counts,
                    err.220.cpm = err.220.cpm,
                    err.220.2by = err.220.2by,
                    err.220 = err.220,
                    counts.220 = counts.220,
                    err.219.cpm = err.219.cpm,
                    err.219.2by = err.219.2by,
                    err.219 = err.219,
                    counts.219 = counts.219,
                    # Background
                    cc.220 = cc.220,
                    err.cc.220 = err.cc.220,
                    x = x,
                    err.x = err.x,
                    cc.219 = cc.219,
                    err.cc.219 = err.cc.219,
                    y = y,
                    err.y = err.y,
                    # Correction
                    corr.220 = corr.220,
                    err.corr.220 = err.corr.220,
                    corr.219 = corr.219,
                    err.corr.219 = err.corr.219) )
}

# source("functions/read_rn.R")
# process_rn(read_rn("data/AL557/Count1/050621_1grey_St3.txt"))
