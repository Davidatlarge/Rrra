# function to identify if the data in a file is from
# a sample, a sample blank, a standard, or a standard blank
# look for this information in the file name 
identify_type <- function(string # generally a file name
) {
  # remove leading path from file names
  string <- sub(".*[\\\\|/]", "", string)
  # identify type of sample in filename
  if(grepl("standard|std", string, ignore.case = TRUE) &
     grepl("blank", string, ignore.case = TRUE)) {
    type <- "standard_blank"
  } else if(grepl("standard|std", string, ignore.case = TRUE)) {
    type <- "standard"
  } else if(grepl("blank", string, ignore.case = TRUE)) {
    type <- "blank"
  } else {
    type <- "sample"
  }
  # add the isotope number to standards, if any
  if(grepl("standard", type)) { 
    type <- paste0(sub(".*(223|224).*", "\\1", string), "_", type) 
  }
  
  return(type)
}

# identify_type("050621_1grey_St3.txt")
# identify_type("050621_1grey_St10_blank.txt")
# identify_type("050621_1orange_223Rastandard.txt")
# identify_type("060621_blue_223STD_blank.txt")
