# calculates those parameter of the count 1 sheet that need input of efficiency, blanks and filtration volume
# other parameters calculated in count 1 sheet are supplied as a dataframe (pro), the output of process_ra()
mutate_ra <- function(eff,
                      blk,
                      pro,
                      filtration_volume_L,
                      merged.output = TRUE # should the data frame pro be merged to the output of this function
) {
  # efficiency
  detector.eff.223 <- eff$mean[eff$detector==pro$detector & eff$isotope==223]
  detector.eff.223.sd <- eff$sd[eff$detector==pro$detector & eff$isotope==223]
  detector.eff.224 <- eff$mean[eff$detector==pro$detector & eff$isotope==224]
  detector.eff.224.sd <- eff$sd[eff$detector==pro$detector & eff$isotope==224]
  
  effic <- (((detector.eff.223*2)*(pro$CPM219-pro$cc.219))^2*0.01) / (1+((detector.eff.223*2)*(pro$CPM219-pro$cc.219))*0.01) # very minor difference from excel, when copying the efficiency value
  
  # Final 220 values
  detector.blank.220 <- blk$mean[blk$detector==pro$detector & blk$isotope==224]
  
  final.220 <- pro$corr.220-effic-detector.blank.220
  err.final.220 <- pro$err.corr.220
  dpm.220 <- final.220/detector.eff.224
  err.dpm.220 <- sqrt( (err.final.220/detector.eff.224)^2 + (final.220*detector.eff.224.sd/detector.eff.224)^2 )
  dpm.220per100L <- dpm.220/filtration_volume_L*100
  err.dpm.220per100L <- sqrt( (err.dpm.220/filtration_volume_L)^2 + (dpm.220*filtration_volume_L*0.03/filtration_volume_L^2)^2 ) * 100
  
  # Final 219 values
  qm <- sqrt(pro$CPM220*pro$Runtime) / (pro$CPM220*pro$Runtime) # qm means questionmark, thats in the excel sheet - NOT USED LATER?!
  final.219 <- pro$corr.219 - pro$corr.220*0.0255 # c1$corr.220*0.0255 is "219 from 220" in excel
  err.final.219 <- sqrt(pro$err.corr.219^2 + (0.0255*pro$err.corr.220)^2)
  dpm.219 <- final.219/detector.eff.223
  err.dpm.219 <- sqrt( (err.final.219/detector.eff.223)^2 + (final.219*detector.eff.223.sd/detector.eff.223^2)^2 ) # the detector.eff.223.sd term is ambiguous in the excel sheet but makes more sense than detector.eff.223
  dpm.219per100L <- dpm.219/filtration_volume_L*100
  err.dpm.219per100L <- sqrt( (err.dpm.219/filtration_volume_L)^2 + (dpm.219*filtration_volume_L*0.03/filtration_volume_L^2)^2 ) * 100
  
  # output
  final <- data.frame(file = sub(".*[\\\\|/]", "", pro$file),
                      effic = effic,
                      final.220 = final.220,
                      err.final.220 = err.final.220,
                      dpm.220 = dpm.220,
                      err.dpm.220 = err.dpm.220,
                      dpm.220per100L = dpm.220per100L,
                      err.dpm.220per100L = err.dpm.220per100L,
                      qm = qm, 
                      final.219 = final.219,
                      err.final.219 = err.final.219,
                      dpm.219 = dpm.219,
                      err.dpm.219 = err.dpm.219,
                      dpm.219per100L = dpm.219per100L,
                      err.dpm.219per100L = err.dpm.219per100L) 
  if(merged.output) {
    final <- merge(pro, final)
  }
  
  return(final)
}

# source("functions/read_ra.R")
# source("functions/summarise_efficiency.R")
# source("functions/summarise_blank.R")
# source("functions/process_ra.R")
# t( mutate_ra(eff = summarise_efficiency(list.files("data/AL557/Standards/", full.names = TRUE)),
#             blk = summarise_blank(list.files("data/AL557/Count1/", full.names = TRUE)),
#             pro = process_ra(read_ra(file = "data/test_case1/050621_1grey_St3.txt")),
#             filtration_volume_L <- 200)
# )
