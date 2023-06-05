# function to identify if the data in a file is from
# a sample, a sample blank, a standard, or a standard blank
# look for this information in the file name 
# args blank.id and standard.id take quoted strings that identify blanks and standards in the file name
# multiple options can be passed using the | character, e.g. "standard|std"
# the seach for th IDs in the file name is case-insensitive, so "STD" and "Std" will both work
identify_type <- function(string, # generally a file name
                          blank.id = "blank", 
                          standard.id = "standard|std" 
) {
  # remove leading path from file names
  string <- sub(".*[\\\\|/]", "", string)
  # identify type of sample in filename
  if(grepl(standard.id, string, ignore.case = TRUE) &
     grepl(blank.id, string, ignore.case = TRUE)) {
    type <- "standard_blank"
  } else if(grepl(standard.id, string, ignore.case = TRUE)) {
    type <- "standard"
  } else if(grepl(blank.id, string, ignore.case = TRUE)) {
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
