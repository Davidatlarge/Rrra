Rrra
================
David Kaiser

## intro

R toolbox for processing of Radium data from RaDeCC.

## Principal workflow

The main function of this toolbox is `process_samples()`. It accepts a
list of files that contains the sample but possibly also other
measurement files, data frames containing values for measurement blanks,
for detector efficiency values and meta data, as well as some additional
arguments.

The files for samples, blanks and standards can be located in the same
folder/path.

``` r
files <- list.files("data/test_case1/", recursive = TRUE, full.names = TRUE, pattern = ".txt$")
```

The meta data is supplied in a simple table. A wrapper for a read
function to access excel sheets will follow soon.

``` r
meta <- data.frame(id = c("St2", "St3", "St5"),
                   sampling.time = as.POSIXct(c("2021-06-05 09:43:00", "2021-06-05 09:52:00", "2021-06-15 09:52:00")),
                   volume = c(200.4, 200.5, 220.5))
meta
```

    ##    id       sampling.time volume
    ## 1 St2 2021-06-05 09:43:00  200.4
    ## 2 St3 2021-06-05 09:52:00  200.5
    ## 3 St5 2021-06-15 09:52:00  220.5

Also, we can define those arguments used multiple times.

``` r
detec = c("orange","blue","grey","green")
datef = "%m/%d/%Y"
standard.id = "standard|std"
blank.id = "blank"
```

The function `summarise_blank()` finds, processes and summarises files
containing blank measurements. To identify blanks from the file name, it
accepts input to the argument `blank.id`, and to properly summarise, it
accepts a vector of detector names in `detectors`. The detector names
should be part of the file name. A warning will be printed if less than
3 values are used in a summary.

``` r
blk <- summarise_blank(files,
                       date.format = datef, 
                       detectors = detec, 
                       blank.id = blank.id, 
                       summarise = TRUE)
head(blk)
```

    ##   detector isotope        mean         sd  n
    ## 1     blue     223 0.000000000 0.00000000  9
    ## 2    green     223 0.000000000 0.00000000  6
    ## 3     grey     223 0.000000000 0.00000000 10
    ## 4   orange     223 0.000000000 0.00000000 10
    ## 5     blue     224 0.009555556 0.01435367  9
    ## 6    green     224 0.010166667 0.01925011  6

Similarly, `summarise_efficiency()` finds and works with files
containing standard measurements. It additionally takes input for
`standard.id`, as well as DPM values for the standards used.

``` r
eff <- summarise_efficiency(files,
                            date.format = datef, 
                            detectors = detec,
                            standard.id = standard.id, 
                            blank.id = blank.id,
                            dpm.223.std = 9.94, # Personal Comm Walter Geibert (AWI)
                            dpm.224.std = 12.1, # Personal Comm Walter Geibert (AWI)
                            summarise = TRUE)
```

    ## some efficiencies have been calculated with fewer than 3 standard values

``` r
head(eff)
```

    ##   detector isotope       mean         sd n
    ## 1     blue     223 0.16719556         NA 1
    ## 2    green     223 0.16171887 0.02599217 2
    ## 3     grey     223 0.15970596 0.01436684 3
    ## 4   orange     223 0.15368312 0.02965712 5
    ## 5     blue     224 0.06786601 0.01166152 2
    ## 6    green     224 0.07783872         NA 1

Finally, `process_samples()` takes the meta data, output from
`summarise_blank()` and `summarise_efficiencies()`, as well as the blank
and standard identifiers and an estimate for 227Ac. The detector names
are extracted from the inputs to `blk` and `eff`. With `verbose = TRUE`
comes a stream of information about file processing, printed to the
console. Setting `halfway = TRUE` returns a table of all the values for
each sample file that are used for the final calculation of results. All
these functions also accept the strptime-style `date.format` to enable
correctly converting to POSIXct the Start Time and Stop Time in files
created by different system time settings.

``` r
out <- process_samples(files = files,
                       blk = blk, 
                       eff = eff, 
                       meta = meta,
                       date.format = datef, 
                       standard.id = standard.id, 
                       blank.id = blank.id,
                       estimate.227Ac = 0.05,
                       halfway = FALSE, 
                       verbose = TRUE)
```

    ## identified detectors: 'blue', 'green', 'grey', 'orange'

    ## identified sample 'St3' in file '050621_1grey_St3.txt'

    ## matching sample 'St3' with meta data id 'St3', with sampling time '2021-06-05 09:52:00' and filtration volume 200.5 L

    ## identified sample 'St2' in file '050621_2blue_St2.txt'

    ## matching sample 'St2' with meta data id 'St2', with sampling time '2021-06-05 09:43:00' and filtration volume 200.4 L

    ## identified sample 'St5' in file '050621_2blue_St5_only_one_count.txt'

    ## matching sample 'St5' with meta data id 'St5', with sampling time '2021-06-15 09:52:00' and filtration volume 220.5 L

    ## identified sample 'st8' in file '050621_blue_st8_not_in_meta.txt'

    ## Warning in process_samples(files = files, blk = blk, eff = eff, meta
    ## = meta, : no unique sample with id 'st8' found in meta. Skipping file
    ## '050621_blue_st8_not_in_meta.txt'

    ## identified sample 'St3' in file '130621_green_St3_2.txt'

    ## matching sample 'St3' with meta data id 'St3', with sampling time '2021-06-05 09:52:00' and filtration volume 200.5 L

    ## identified sample 'St3' in file '130621_green_St3_3dummy.txt'

    ## matching sample 'St3' with meta data id 'St3', with sampling time '2021-06-05 09:52:00' and filtration volume 200.5 L

    ## identified sample 'St3' in file '130621_green_St3_4dummy.txt'

    ## matching sample 'St3' with meta data id 'St3', with sampling time '2021-06-05 09:52:00' and filtration volume 200.5 L

    ## identified sample 'St2' in file '130621_orange_St2_2.txt'

    ## matching sample 'St2' with meta data id 'St2', with sampling time '2021-06-05 09:43:00' and filtration volume 200.4 L

    ## identified sample 'St224Ra' in file '290621_orange_St224Ra.txt'

    ## Warning in process_samples(files = files, blk = blk, eff = eff, meta =
    ## meta, : no unique sample with id 'St224Ra' found in meta. Skipping file
    ## '290621_orange_St224Ra.txt'

    ## in sample 'St2'

    ##   count       sampling.time            midpoint                    file
    ## 2     1 2021-06-05 09:43:00 2021-06-05 10:56:05    050621_2blue_St2.txt
    ## 7     2 2021-06-05 09:43:00 2021-06-13 18:27:51 130621_orange_St2_2.txt

    ## in sample 'St3'

    ##   count       sampling.time            midpoint                        file
    ## 1     1 2021-06-05 09:52:00 2021-06-05 12:17:29        050621_1grey_St3.txt
    ## 4     2 2021-06-05 09:52:00 2021-06-13 21:15:46      130621_green_St3_2.txt
    ## 5     3 2021-06-05 09:52:00 2021-06-15 21:15:46 130621_green_St3_3dummy.txt
    ## 6     4 2021-06-05 09:52:00 2021-06-20 21:15:46 130621_green_St3_4dummy.txt

    ## more than 2 counts for sample id 'St3', ignoring file/s '130621_green_St3_3dummy.txt', '130621_green_St3_4dummy.txt'

    ## Warning in process_samples(files = files, blk = blk, eff = eff,
    ## meta = meta, : less than 2 counts for sample id 'St5', skipping file
    ## '050621_2blue_St5_only_one_count.txt'

``` r
out
```

    ##   Ra224.DPMper100L err.Ra224.DPMper100L Ra223.DPMper100L err.Ra223.DPMper100L
    ## 1        62.020833            3.8307499         1.836055                   NA
    ## 2         8.891804            0.6255243         0.783590            0.1720034
    ##    id
    ## 1 St2
    ## 2 St3

## under the hood

### file handling

`files` (paths to files) can be different for samples, blanks and
standards, but can also be the same, i.e. all relevant files can be in
one folder. Internally, `summarise_blank()`, `summarise_efficiency()`
and `process_samples()` call `identify_type()`, which inherits
`blank.id` and `standard.id` and uses their values to identify the
measurement type from the file name.

``` r
identify_type(string = "050621_1grey_St10_blank.txt", blank.id = blank.id, standard.id = standard.id)
```

    ## [1] "blank"

``` r
identify_type(string = "050621_1orange_228Rastandard.txt", blank.id = blank.id, standard.id = standard.id)
```

    ## [1] "228_standard"

``` r
identify_type(string = "060621_blue_223STD_blank.txt", blank.id = blank.id, standard.id = standard.id)
```

    ## [1] "223_standard_blank"

``` r
identify_type(string = "St1_224standard_20200223", blank.id = blank.id, standard.id = standard.id)
```

    ## [1] "224_standard"

``` r
identify_type(string = "St223_224standard_20200223", blank.id = blank.id, standard.id = standard.id)
```

    ## [1] "223_standard"

If neither `blank.id` nor `standard.id` value is found in the string,
the measurement is assumed to be from a sample. It is thus not necessary
to name samples as such, but is also is no disadvantage.

``` r
identify_type(string = "050621_1grey_St3.txt", blank.id = blank.id, standard.id = standard.id)
```

    ## [1] "sample"

``` r
identify_type(string = "050621_1grey_St3.txt", blank.id = "something", standard.id = "other")
```

    ## [1] "sample"

Only supplying one identifier does work but is not recommended. Only
supplying `standard.id` results in a warning, because it is then
possible to *mis*identify blanks that were measured before standards
(i.e. standard blanks) as standards rather than the blanks they are.

``` r
identify_type(string = "070621_orange_224STD_blank.txt", standard.id = standard.id)
```

    ## Warning in identify_type(string = "070621_orange_224STD_blank.txt", standard.id
    ## = standard.id): identifying standards but not blanks might misinterpret
    ## standard-blanks in '070621_orange_224STD_blank.txt'

    ## [1] "224_standard"

Once the `files` have been filtered for the respective measurement type,
the top functions call `read_ra()` on each of those files. `read_ra()`
returns a list with all the content of the file.

``` r
Ra <- read_ra(file = "data/test_case1/samples/050621_1grey_St3.txt", detectors = detec, date.format = datef)
Ra$counts <- head(Ra$counts) # for better readability
Ra
```

    ## $filename
    ## [1] "050621_1grey_St3.txt"
    ## 
    ## $original.filename
    ## [1] "050621_1grey_St3.txt"
    ## 
    ## $id
    ## [1] "St3"
    ## 
    ## $detector
    ## [1] "grey"
    ## 
    ## $start.time
    ## [1] "2021-06-05 09:52:46 CEST"
    ## 
    ## $end.time
    ## [1] "2021-06-05 12:17:29 CEST"
    ## 
    ## $count.summary
    ##   Runtime CPM219 Cnt219 CPM220 Cnt220 CPMTot CntTot
    ## 1  144.72  0.304     44  3.262    472 11.284   1633
    ## 
    ## $counts
    ##   Runtime CPM219 Cnt219 CPM220 Cnt220 CPMTot CntTot
    ## 1       1   0.00      0  6.000      6 21.000     21
    ## 2       2   0.00      0  4.000      2 14.000      7
    ## 3       3   0.00      0  2.667      0 10.667      4
    ## 4       4   0.25      1  2.250      1 10.750     11
    ## 5       5   0.60      2  3.400      8 12.600     20
    ## 6       6   0.50      0  3.333      3 12.167     10

The sample ID, `Ra$id` is defined as any string including the (last)
occurrence of “St” but before the next “\_” or before the “.txt”
extension. This is case-insensitive. For example, `050621_2blue_St2.txt`
becomes `St2`, `050621_orange_st1cont.txt` becomes `st1cont`,
`050621_st6grey_.txt` becomes `st6grey`. A cruise ID or other info can
be tacked on as long as it is not separated by “\_“:
`140621_blue_st5-AlkorCruise_2.txt` becomes `st5-AlkorCruise` but
`140621_blue_st5_AlkorCruise_2.txt` becomes `st5`. This created a slight
nuisance because standards, that might not have station names, will get
a wrong ID, e.g. `20220101_223Standard_2.txt` would become `Standard`.
In effect this is not important because the ID of standards is not used
in the workflow (other than the samples, who are processed in groups
defined by ID).

### data processing

In `summarise_blank()` the outputs of each file are summarised grouped
by detector and Ra isotope. In `summarise_blank()` some calculations for
detector efficiencies are performed before summarising.

In `process_samples()`, `process_ra()` takes the output of `read_ra()`
and returns values that can be derived solely from the data in one
measurement result file.

``` r
pro <- process_ra(Ra)
t( pro ) # transpose for better readability here
```

    ##               [,1]                  
    ## file          "050621_1grey_St3.txt"
    ## detector      "grey"                
    ## start.time    "2021-06-05 09:52:46" 
    ## Runtime       "144.72"              
    ## midpoint      "2021-06-05 12:17:29" 
    ## CPMTot        "11.284"              
    ## CPM219        "0.304"               
    ## CPM220        "3.262"               
    ## err.total.cpm "0.2792333"           
    ## total.counts  "1633.02"             
    ## err.220.cpm   "0.1501335"           
    ## err.220.2by   "0.09204999"          
    ## err.220       "0.05138956"          
    ## counts.220    "472.0766"            
    ## err.219.cpm   "0.04583239"          
    ## err.219.2by   "0.3015289"           
    ## err.219       "0.04522912"          
    ## counts.219    "43.99488"            
    ## cc.220        "0.6454945"           
    ## err.cc.220    "0.05582238"          
    ## x             "7.718"               
    ## err.x         "0.320331"            
    ## cc.219        "0.004654953"         
    ## err.cc.219    "0.001865508"         
    ## y             "8.363495"            
    ## err.y         "0.3251585"           
    ## corr.220      "2.616505"            
    ## err.corr.220  "0.1601756"           
    ## corr.219      "0.299345"            
    ## err.corr.219  "0.04587034"

`mutate_ra()` takes the output of `summarise_efficiency()`,
`summarise_blank()` (inherited from the top function) and
`process_ra()`, as well as additional metadata to return more derived
values. With the argument `merged.output = TRUE` (the default) the new
values will be added to the output of `process_ra()` (this is only
useful if the functions are run outside the main workflow).

``` r
final <- mutate_ra(eff = eff, 
                   blk = blk,
                   pro = pro,
                   filtration_volume_L = 200.5, 
                   merged.output = TRUE)
t( # transpose for better readability here
  final[!(names(final)%in%names(pro))] # show only those columns not in the output of process_ra()
   )
```

    ##                            [,1]
    ## effic              9.133376e-05
    ## final.220          2.589414e+00
    ## err.final.220      1.601756e-01
    ## dpm.220            3.305285e+01
    ## err.dpm.220        2.103184e+00
    ## dpm.220per100L     1.648521e+01
    ## err.dpm.220per100L 1.159708e+00
    ## qm                 4.602499e-02
    ## final.219          2.326242e-01
    ## err.final.219      4.605183e-02
    ## dpm.219            1.456578e+00
    ## err.dpm.219        3.167287e-01
    ## dpm.219per100L     7.264727e-01
    ## err.dpm.219per100L 1.594657e-01

The results are then grouped by the samples´ `id`.

``` r
# example count measurements of the same sample
c1 <- read_ra("data/test_case1/samples/050621_1grey_St3.txt", detec, datef) %>% process_ra() %>% mutate_ra(eff, blk, ., 200.5)
c2 <- read_ra("data/test_case1/samples/130621_green_St3_2.txt", detec, datef) %>% process_ra() %>% mutate_ra(eff, blk, ., 200.5)
```

`onFiber_228Th` estimates the amount of 228Th on the fiber to determine
the ingrowth of decaying 228Th.

``` r
onFiber228Th <- onFiber_228Th(midpoint.1 = c1$midpoint, 
                              midpoint.2 = c2$midpoint, 
                              dpm.220per100L.1 = c1$dpm.220per100L,
                              dpm.220per100L.2 = c2$dpm.220per100L)
onFiber228Th
```

    ## [1] 10.86755

The results are then calculated from the processed values of the first
measurement/count using `results_Ra()`.

``` r
results <- results_Ra(count1 = c1, 
                      sampling.time = as.POSIXct("2021-06-05 09:52:00"), 
                      onFiber228Th = onFiber228Th, 
                      estimate.227Ac = 0.05)
results
```

    ##   Ra224.DPMper100L err.Ra224.DPMper100L Ra223.DPMper100L err.Ra223.DPMper100L
    ## 1         8.891804            0.6255243          0.78359            0.1720034

The results of all samples are returned in one data frame.

## Error cases

`read_ra()`: Files with missing ends. Incorrect detector name supplied.
Wrong date format supplied.

``` r
Ra <- read_ra("data/AL557/Count1/050621_1orange_St1.txt", detectors = "pink", date.format = "Y%m%d%")
```

    ## Warning in read_ra("data/AL557/Count1/050621_1orange_St1.txt", detectors = "pink", : Detector not found in 050621_1orange_St1.txt. Returning NA.
    ##  Have you supplied the correct potential detector name?

    ## Warning in read_ra("data/AL557/Count1/050621_1orange_St1.txt",
    ## detectors = "pink", : Count Summary not available in
    ## data/AL557/Count1/050621_1orange_St1.txt. Returning NA

    ## Warning in read_ra("data/AL557/Count1/050621_1orange_St1.txt", detectors = "pink", : Could not find Start Time in the provided date format. Returning NA.
    ##  The supplied format is 'Y%m%d%'. In the file it is 'Start Time 6/5/2021  11:50:32'.

    ## Warning in read_ra("data/AL557/Count1/050621_1orange_St1.txt",
    ## detectors = "pink", : Stop Time not available in
    ## file:data/AL557/Count1/050621_1orange_St1.txt. Returning NA.

``` r
Ra$counts <- head(Ra$counts)
Ra
```

    ## $filename
    ## [1] "050621_1orange_St1.txt"
    ## 
    ## $original.filename
    ## [1] "050621_1orange_St1.txt"
    ## 
    ## $id
    ## [1] "St1"
    ## 
    ## $detector
    ## [1] NA
    ## 
    ## $start.time
    ## [1] NA
    ## 
    ## $end.time
    ## [1] NA
    ## 
    ## $count.summary
    ## [1] NA
    ## 
    ## $counts
    ##   Runtime CPM219 Cnt219 CPM220 Cnt220 CPMTot CntTot
    ## 1    0.98  0.000      0 11.186     11 26.441     26
    ## 2    1.98  0.000      0 10.084      9 23.697     21
    ## 3    2.98  1.006      3  9.385      8 25.810     30
    ## 4    3.98  0.753      0 10.544     14 26.862     30
    ## 5    4.98  0.803      1 12.241     19 29.498     40
    ## 6    6.00  0.667      0 12.667     15 29.167     28

`identify_type()`: Not supplying either identifier stops the function.

``` r
identify_type(string = "050621_1grey_St3.txt")
```

    ## Error in identify_type(string = "050621_1grey_St3.txt"): at least one of 'blank.id' or 'standard-id' must be supplied

`summarise_blank()`: No blanks in `files` stops the function

``` r
summarise_blank("data/test_case1/samples/", detectors = detec, date.format = filef, blank.id = blank.id)
```

    ## Error in summarise_blank("data/test_case1/samples/", detectors = detec, : no blanks indentified in input files

`summarise_efficiency()`: no standards in `files` stops the function

``` r
summarise_efficiency("data/test_case1/samples/", detectors = detec, date.format = filef, blank.id = blank.id, standard.id = standard.id, dpm.223.std = 10, dpm.224.std = 12)
```

    ## Error in summarise_efficiency("data/test_case1/samples/", detectors = detec, : no standards indentified in input files

`process_ra()`: missing or incomplete summary stops the function, so
does missing Start Time

``` r
process_ra(read_ra("data/AL557/Count1/050621_1orange_St1.txt", detectors = detec, date.format = datef))
```

    ## Warning in read_ra("data/AL557/Count1/050621_1orange_St1.txt",
    ## detectors = detec, : Count Summary not available in
    ## data/AL557/Count1/050621_1orange_St1.txt. Returning NA

    ## Warning in read_ra("data/AL557/Count1/050621_1orange_St1.txt",
    ## detectors = detec, : Stop Time not available in
    ## file:data/AL557/Count1/050621_1orange_St1.txt. Returning NA.

    ## Error in process_ra(read_ra("data/AL557/Count1/050621_1orange_St1.txt", : Summary missing in the Ra with file name '050621_1orange_St1.txt'.

`mutate_ra()`: the function stops if the `pro` object’s detector has no
match in the `blk` or `eff` object

*example coming*

`results_ra()`: the function stops if the times are not supplied
correctly or in the correct order

``` r
results_Ra(count1 = c1, sampling.time = as.POSIXct("2023-12-31 12:12:12"), onFiber228Th = onFiber228Th, estimate.227Ac = 0.05)
```

    ## Error in results_Ra(count1 = c1, sampling.time = as.POSIXct("2023-12-31 12:12:12"), : sampling.time must be earlier than the midpoint of count1

`process_samples()`: multiple warnings, see above. Wrong meta data
formats or no samples in `files` stops the function.

``` r
process_samples(files = list.files("data/test_case1/blanks/", pattern = ".txt$", full.names = TRUE), 
                blk, eff, meta, datef, blank.id, standard.id, estimate.227Ac = 0.05)
```

    ## Error in process_samples(files = list.files("data/test_case1/blanks/", : no samples indentified in input files

# next

- solve this problem:
  - `identify_type(string = "St223_224standard_20200223", blank.id = "blank", standard.id = "standard|std")`
- data output
  - which meta data should be part of the output of process_samples()?
  - should results_Ra() return the decay factors? (currently it doesn’t)
  - should summarise_blank() return values for CPMTot? (currently it
    does but is not used downstream)
- code clean-up
  - change function and argument names to something nicer
  - get rid of unnecessary ()
  - remove objects not needed downstream
  - unify the use of . and \_ in function and argument names
  - remove comments that are notes for the process (e.g. comparisons
    with excel)
- error handling

# probably dumb questions

- how come sampling time only comes in at results_ra()?
- why use half life of 224Ra when correcting for 228Th decay ingrowth?
  e.g. in onFiber_228Th()
- in excel sheet blanks cols P and L seem to link to the wrong cols, no
  downstream effect though.
- it seems that the standards for efficiency are not blank corrected,
  but there are standard blanks, is this a problem?
