# load function
sapply(list.files("functions/", full.names = T), source)

# manual/constants
estimate.227Ac <- 0.05
decay.constant.224Ra <- log(2)/3.66 # 3.66 is 224Rn half life
decay.constant.223Ra <- log(2)/11.4 # 11.4 is 223Rn half life

# metadata
filtration_volume_L <- 200.5
sampling.time = as.POSIXct("2021-06-04 10:29:00")

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

# Decay Factor - is this used again?
decay.factor223 <- decay_factor(223, midpoint = midpoint, sampling.time = sampling.time) # not the same as in excel - rounding?!
decay.factor224 <- decay_factor(224, midpoint = midpoint, sampling.time = sampling.time) # not the same as in excel - rounding?!

#
# MISSING PARTS ARE HANDLED BY process_rn() AND CAN BE TAKEN BACK FROM THERE EASILY
#

# efficiency - THIS IS COVERED BY final_rn()
detector.eff.223 <- eff$mean[eff$detector==detector & eff$isotope==223]
detector.eff.223.sd <- eff$sd[eff$detector==detector & eff$isotope==223]
detector.eff.224 <- eff$mean[eff$detector==detector & eff$isotope==224]
detector.eff.224.sd <- eff$sd[eff$detector==detector & eff$isotope==224]
effic <- (((detector.eff.223*2)*(CPM219-cc.219))^2*0.01) / (1+((detector.eff.223*2)*(CPM219-cc.219))*0.01) # very minor difference from excel, when copying the efficiency value

# Final - THIS IS COVERED BY final_rn()
detector.blank.220 <- blk$mean[blk$detector==detector & blk$isotope==224]

final.220 <- corr.220-effic-detector.blank.220
err.final.220 <- err.corr.220
dpm.220 <- final.220/detector.eff.224
err.dpm.220 <- sqrt( (err.final.220/detector.eff.224)^2 + (final.220*detector.eff.224.sd/detector.eff.224)^2 )
dpm.220per100L <- dpm.220/filtration_volume_L*100
err.dpm.220per100L <- sqrt( (err.dpm.220/filtration_volume_L)^2 + (dpm.220*filtration_volume_L*0.03/filtration_volume_L^2)^2 ) * 100

# Derived from Count 2
10.33
dpm.220.c2 <- 23.49
time.since.count1 <- 8.37
dpm.220.c2.per100L <- dpm.220.c2/filtration_volume_L*100
fiber.228Th <- (dpm.220per100L-(dpm.220.c2.per100L*exp(decay.constant.224Ra*time.since.count1))) / (1-exp(decay.constant.224Ra*time.since.count1))

# Decay Corrected. - these are the final values but depend on count 2
decay.corr.dpm.220.100L <- (dpm.220per100L-fiber.228Th)/decay.factor224
err.decay.corr.dpm.220.100L <- (err.dpm.220per100L/dpm.220per100L)*decay.corr.dpm.220.100L

# Th estimate
rel.err.228Th <- err.decay.corr.dpm.220.100L/decay.corr.dpm.220.100L
est.228Th.dpm.100L <- sqrt(CPM220*Runtime-cc.220*Runtime) / (CPM220*Runtime-cc.220*Runtime)

# Final 224 Values
Ra224.dpm.100L <- decay.corr.dpm.220.100L
err.Ra224.dpm.100L <- err.decay.corr.dpm.220.100L
err.Ra224.percent <- err.decay.corr.dpm.220.100L/decay.corr.dpm.220.100L*100

# Calculating 219 from 220
qm <- sqrt(CPM220*Runtime)/(CPM220*Runtime) # qm means questionmark, thats in the excel sheet
from.220 <- corr.220*0.0255
final.219 <- corr.219-from.220
err.final.219 <- sqrt(err.corr.219^2 + (0.0255*err.corr.220)^2)
dpm.219 <- final.219/detector.eff.223
err.dpm.219 <- sqrt( (err.final.219/detector.eff.223)^2 + (final.219*detector.eff.223.sd/detector.eff.223^2)^2 ) # the detector.eff.223.sd term is ambiguous in the excel sheet but makes more sense than detector.eff.223
dpm.219per100L <- dpm.219/filtration_volume_L*100
err.dpm.219per100L <- sqrt( (err.dpm.219/filtration_volume_L)^2 + (dpm.219*filtration_volume_L*0.03/filtration_volume_L^2)^2 ) * 100

decay.corr.dpm.219.100L <- (dpm.219per100L-estimate.227Ac)/decay.factor223
err.decay.corr.dpm.219.100L <- (err.dpm.219per100L/dpm.219per100L)*decay.corr.dpm.219.100L

# Final 223 Values
Ra223.dpm.100L <- decay.corr.dpm.219.100L
err.Ra223.dpm.100L <- err.decay.corr.dpm.219.100L
err.Ra223.percent <- err.decay.corr.dpm.219.100L/decay.corr.dpm.219.100L*100
