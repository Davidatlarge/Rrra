# function to identify if the data in a file is from
# a sample, a sample blank, a standard, or a standard blank
# look for this information in the file name 
# args blank.id and standard.id take quoted strings that identify blanks and standards in the file name
# multiple options can be passed using the | character, e.g. "standard|std"
# the search for th IDs in the file name is case-insensitive, so "STD" and "Std" will both work
identify_type <- function(string, # generally a file name
                          standard.id,
                          blank.id
) {
  # handle missing arguments
  if(missing(standard.id) & missing(blank.id)) stop("at least one of 'standard.id' or 'blank.id' arguments must be supplied")
  
  # remove leading path from file names
  string <- sub(".*[\\\\|/]", "", string)
  
  # identify type of sample in file name
  is_std <- if(!missing(standard.id)) grepl(standard.id, string, ignore.case = TRUE) else FALSE
  is_blk <- if(!missing(blank.id)) grepl(blank.id, string, ignore.case = TRUE) else FALSE
  
  if(is_std & is_blk) {
    type <- "standard_blank"
  } else if(is_std) {
    type <- "standard"
  } else if(is_blk) {
    type <- "blank"
  } else {
    type <- "sample"
  }
  
  # add the isotope number to standards, if any
  if(grepl("standard", type) &
     grepl("223|224", string)
  ) { 
    type <- paste0(sub(".*(223|224).*", "\\1", string), "_", type) 
  }
  
  return(type)
}

# identify_type(string = "050621_1grey_St3.txt")
# identify_type(string = "050621_1grey_St3.txt", blank.id = "blank", standard.id = "standard|std")
# identify_type(string = "050621_1grey_St10_blank.txt", blank.id = "blank")
# identify_type(string = "050621_1orange_228Rastandard.txt", blank.id = "blank", standard.id = "standard|std")
# identify_type(string = "060621_blue_223STD_blank.txt", blank.id = "blank", standard.id = "standard|std")

