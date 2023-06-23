# function to identify if the data in a file is from
# a sample, a sample blank, a standard, or a standard blank
# look for this information in the file name 
# args blank.id and standard.id take quoted strings that identify blanks and standards in the file name
# multiple options can be passed using the | character, e.g. "standard|std"
# the search for th IDs in the file name is case-insensitive, so "STD" and "Std" will both work
identify_type <- function(string, # generally a file name
                          blank.id, 
                          standard.id 
) {
  # handle missing arguments
  if(missing(blank.id) & missing(standard.id)) stop("at least one of 'blank.id' or 'standard-id' must be supplied")
  if(missing(blank.id) & !missing(standard.id)) warning(paste0("identifying standards but not blanks might misinterpret standard-blanks in '", string, "'"))
  
  # remove leading path from file names
  string <- sub(".*[\\\\|/]", "", string)
  
  # identify type of sample in file name
  is_blk <- if(!missing(blank.id)) grepl(blank.id, string, ignore.case = TRUE) else FALSE
  is_std <- if(!missing(standard.id)) grepl(standard.id, string, ignore.case = TRUE) else FALSE
  
  if(is_blk & is_std) {
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
     grepl("223|224|228", string)
  ) { 
    type <- paste0(sub(".*?(?<!\\d)(22[348])(?!\\d).*", "\\1", string, perl=TRUE), "_", type) 
  }
  
  return(type)
}

# identify_type(string = "050621_1grey_St3.txt")
# identify_type(string = "070621_orange_224STD_blank.txt", standard.id = "standard|std")
# identify_type(string = "050621_1grey_St3.txt", blank.id = "blank", standard.id = "standard|std")
# identify_type(string = "050621_1grey_St10_blank.txt", blank.id = "blank", standard.id = "standard|std")
# identify_type(string = "070621_orange_224STD_blank.txt", standard.id = "standard|std")
# identify_type(string = "050621_1orange_228Rastandard.txt", blank.id = "blank", standard.id = "standard|std")
# identify_type(string = "060621_blue_223STD_blank.txt", blank.id = "blank", standard.id = "standard|std")
# identify_type(string = "St1_224standard_20200223", blank.id = "blank", standard.id = "standard|std")
# identify_type(string = "St223_224standard_20200223", blank.id = "blank", standard.id = "standard|std")


