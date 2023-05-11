# load function
sapply(list.files("functions/", full.names = T), source)

# manual/constants
Estimate.227Ac <- 0.05

# metadata
filtration_volume_L <- 200.5

# get blank summary values
blk <- summarise_blank(list.files("data/AL557/Count1/", full.names = TRUE))

# get detector efficiency summary values
eff <- summarise_efficiency(list.files("data/AL557/Standards/", full.names = TRUE))

# read data
Rn <- read_rn("data/AL557/Count1/050621_1grey_St3.txt")
start.time <- Rn$start.time
Runtime <- Rn$count.summary$Runtime
CPMTot <- Rn$count.summary$CPMTot
CPM220 <- Rn$count.summary$CPM220
CPM219 <- Rn$count.summary$CPM219
detector <- Rn$detector

## process sample
midpoint <- counting_midpoint(start.time = start.time, Runtime = Runtime) # hard to compare with excel cos of different formats

# Decay Factor
decay.factor223 <- decay_factor(223, midpoint = midpoint, sampling.time = as.POSIXct("2021-06-04 10:29:00")) # not the same as in excel - rounding?!
decay.factor224 <- decay_factor(224, midpoint = midpoint, sampling.time = as.POSIXct("2021-06-04 10:29:00")) # not the same as in excel - rounding?!

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
err.corr.220
corr.219 <- CPM219-cc.219
err.corr.219 <- sqrt((err.219.cpm^2)+(err.cc.219^2))

# efficiency
detector.eff.223 <- eff$mean[eff$detector==detector & eff$isotope==223]
detector.eff.223.sd <- eff$sd[eff$detector==detector & eff$isotope==223]
detector.eff.224 <- eff$mean[eff$detector==detector & eff$isotope==224]
detector.eff.224.sd <- eff$sd[eff$detector==detector & eff$isotope==224]
effic <- (((detector.eff.223*2)*(CPM219-cc.219))^2*0.01) / (1+((detector.eff.223*2)*(CPM219-cc.219))*0.01) # very minor difference from excel, when copying the efficiency value

# Final
detector.blank.220 <- blk$mean[blk$detector==detector & blk$isotope==224]

final.220 <- corr.220-effic-detector.blank.220
err.final.220 <- err.corr.220
dpm.220 <- final.220/detector.eff.224
err.dpm.220 <- sqrt( (err.final.220/detector.eff.224)^2 + (final.220*detector.eff.224.sd/detector.eff.224)^2 )
dpm.220per100L <- dpm.220/filtration_volume_L*100
err.dpm.220per100L <- sqrt( (err.dpm.220/filtration_volume_L)^2 + (dpm.220*filtration_volume_L*0.03/filtration_volume_L^2)^2 ) * 100


# Derived from Count 2
# Decay Corrected. - these are the final values but depend on count 2
# Th estimate 
# Final 224 Values - same as Decay corrected

# Calculating 219 from 220
qm <- sqrt(CPM220*Runtime)/(CPM220*Runtime)
from.220 <- corr.220*0.0255
final.219 <- corr.219-from.220
err.final.219 <- sqrt(err.corr.219^2 + (0.0255*err.corr.220)^2)
dpm.219 <- final.219/detector.eff.223
err.dpm.219 <- sqrt( (err.final.219/detector.eff.223)^2 + (final.219*detector.eff.223.sd/detector.eff.223^2)^2 ) # the detector.eff.223.sd term is ambiguous in the excel sheet but makes more sense than detector.eff.223
dpm.219per100L <- dpm.219/filtration_volume_L*100
err.dpm.219per100L <- sqrt( (err.dpm.219/filtration_volume_L)^2 + (dpm.219*filtration_volume_L*0.03/filtration_volume_L^2)^2 ) * 100
