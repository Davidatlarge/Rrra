# calculates thos parameter of the count 1 sheet that need input of efficiency, blanks and fltration volume
# other parameters calculates in count 1 sheet are supplied as a dataframe (pro), the output of process_rn()
final_rn <- function(eff,
                     blk,
                     pro,
                     filtration_volume_L
) {
  # efficiency
  detector.eff.223 <- eff$mean[eff$detector==pro$detector & eff$isotope==223]
  detector.eff.223.sd <- eff$sd[eff$detector==pro$detector & eff$isotope==223]
  detector.eff.224 <- eff$mean[eff$detector==pro$detector & eff$isotope==224]
  detector.eff.224.sd <- eff$sd[eff$detector==pro$detector & eff$isotope==224]
  
  effic <- (((detector.eff.223*2)*(pro$CPM219-pro$cc.219))^2*0.01) / (1+((detector.eff.223*2)*(pro$CPM219-pro$cc.219))*0.01) # very minor difference from excel, when copying the efficiency value
  
  # Final
  detector.blank.220 <- blk$mean[blk$detector==pro$detector & blk$isotope==224]
  
  final.220 <- pro$corr.220-effic-detector.blank.220
  err.final.220 <- pro$err.corr.220
  dpm.220 <- final.220/detector.eff.224
  err.dpm.220 <- sqrt( (err.final.220/detector.eff.224)^2 + (final.220*detector.eff.224.sd/detector.eff.224)^2 )
  dpm.220per100L <- dpm.220/filtration_volume_L*100
  err.dpm.220per100L <- sqrt( (err.dpm.220/filtration_volume_L)^2 + (dpm.220*filtration_volume_L*0.03/filtration_volume_L^2)^2 ) * 100
  
  return(data.frame(file = sub(".*[\\\\|/]", "", pro$file),
                    effic = effic,
                    final.220 = final.220,
                    err.final.220 = err.final.220,
                    dpm.220 = dpm.220,
                    err.dpm.220 = err.dpm.220,
                    dpm.220per100L = dpm.220per100L,
                    err.dpm.220per100L = err.dpm.220per100L) )
}

source("functions/read_rn.R")
source("functions/summarise_efficiency.R")
source("functions/summarise_blank.R")
source("functions/process_rn.R")
final_rn(eff = summarise_efficiency(list.files("data/AL557/Standards/", full.names = TRUE)),
         blk = summarise_blank(list.files("data/AL557/Count1/", full.names = TRUE)),
         pro = process_rn(read_rn(file = "data/AL557/Count1/050621_1grey_St3.txt")),
         filtration_volume_L <- 200)
