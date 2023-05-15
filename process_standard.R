files <- list.files("data/AL557/", recursive = TRUE, full.names = TRUE, pattern = ".txt$")

# get blank summary values
blk <- summarise_blank(files)
# get detector efficiency summary values
eff <- summarise_efficiency(files)

read_ra(files[2])

# for now I assume that StX is the sample identifier
source("functions/read_ra.R")
types <- unlist(lapply(files, function(x) identify_type(x)))
samples <- files[which(types=="sample")]
if(length(samples)<1) {stop("no samples indentified in input files")}

spl <- data.frame()
for(sample in samples) {
  current <- read_ra(sample)
  if(!is.na(current$end.time) & all(!is.na(current$count.summary))) {
      spl <- rbind(spl,
               data.frame(file = sub(".*[\\\\|/]", "", sample),
                          detector = current$detector,
                          start.time = current$start.time,
                          end.time = current$end.time, # may not be needed
                          Runtime = current$count.summary$Runtime,
                          CMP219 = current$count.summary$CPM219,
                          CMP220 = current$count.summary$CPM220,
                          CMPTot = current$count.summary$CPMTot))
  }
}

spl$sample <- sub(".*(st[0-9]+).+", "\\1", spl$file, ignore.case = TRUE)
spl$sample <- tolower(spl$sample)

spl[order(spl$sample),]
