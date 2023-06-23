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
accepts a vector of detector names in `detectors`. A warning will be
printed if less than 3 values are used in a summary.

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
these functions also accept the `date.format` to enable the use of files
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
one folder

EDIT: the sample ID is now defined as anything including the (last)
occurrence of “St” but before the next “\_” or before the “.txt”
extension. This is case-insensitive.

Examples:  
`050621_2blue_St2.txt` becomes `St2`  
`140621_blue_st5-AlkorCruise_2.txt` becomes `st5-AlkorCruise`  
but  
`140621_blue_st5_AlkorCruise_2.txt` becomes `st5`  
`050621_orange_st1cont.txt` becomes `st1cont` `050621_st6grey_.txt`
becomes `st6grey`

## read data from RaDeCC output file

`read_ra()` returns a list with all the content of the file. The
detector names that should be part of the file name can be supplied as
an argument `detectors`. The date format for the Start Time and Stop
Time in the file is supplied in strptime-style via `date.format`.

``` r
Ra <- read_ra(file = "data/test_case1/samples/050621_1grey_St3.txt", detectors = detec, date.format = datef) # these are current default values in the function
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
    ##     Runtime CPM219 Cnt219 CPM220 Cnt220 CPMTot CntTot
    ## 1      1.00  0.000      0  6.000      6 21.000     21
    ## 2      2.00  0.000      0  4.000      2 14.000      7
    ## 3      3.00  0.000      0  2.667      0 10.667      4
    ## 4      4.00  0.250      1  2.250      1 10.750     11
    ## 5      5.00  0.600      2  3.400      8 12.600     20
    ## 6      6.00  0.500      0  3.333      3 12.167     10
    ## 7      7.00  0.429      0  2.857      0 11.571      8
    ## 8      8.00  0.375      0  2.750      2 11.000      7
    ## 9      9.02  0.333      0  2.662      2 10.314      5
    ## 10    10.02  0.399      1  2.696      3 10.383     11
    ## 11    11.00  0.364      0  2.545      1  9.818      4
    ## 12    12.00  0.417      1  2.417      1  9.667      8
    ## 13    13.00  0.385      0  2.385      2  9.231      4
    ## 14    14.02  0.357      0  2.212      0  8.989      6
    ## 15    15.02  0.333      0  2.198      2  8.923      8
    ## 16    16.00  0.313      0  2.188      2  8.938      9
    ## 17    17.02  0.294      0  2.116      1  8.697      5
    ## 18    18.02  0.278      0  2.220      4  8.714      9
    ## 19    19.02  0.263      0  2.577      9  9.150     17
    ## 20    20.02  0.250      0  2.998     11  9.842     23
    ## 21    21.02  0.238      0  2.998      3  9.992     13
    ## 22    22.02  0.227      0  2.952      2  9.856      7
    ## 23    23.02  0.261      1  2.867      1  9.732      7
    ## 24    24.02  0.250      0  2.956      5  9.910     14
    ## 25    25.02  0.240      0  2.998      4 10.073     14
    ## 26    26.02  0.231      0  2.921      1  9.840      4
    ## 27    27.03  0.259      1  2.922      3  9.914     12
    ## 28    28.03  0.250      0  2.961      4  9.952     11
    ## 29    29.02  0.276      1  2.964      3 10.063     13
    ## 30    30.02  0.267      0  3.032      5 10.261     16
    ## 31    31.02  0.258      0  3.063      4 10.317     12
    ## 32    32.03  0.281      1  2.997      1 10.271      9
    ## 33    33.03  0.333      2  3.058      5 10.323     12
    ## 34    34.03  0.323      0  2.997      1 10.167      5
    ## 35    35.02  0.314      0  3.056      5 10.424     19
    ## 36    36.03  0.305      0  3.025      2 10.352      8
    ## 37    37.03  0.324      1  3.051      4 10.450     14
    ## 38    38.03  0.316      0  2.997      1 10.254      3
    ## 39    39.03  0.307      0  3.023      4 10.273     11
    ## 40    40.03  0.300      0  3.022      3 10.266     10
    ## 41    41.03  0.317      1  3.046      4 10.333     13
    ## 42    42.05  0.309      0  3.092      5 10.392     13
    ## 43    43.05  0.325      1  3.066      2 10.383     10
    ## 44    44.03  0.318      0  2.998      0 10.265      5
    ## 45    45.03  0.311      0  3.042      5 10.348     14
    ## 46    46.03  0.304      0  3.041      3 10.384     12
    ## 47    47.05  0.319      1  3.039      3 10.414     12
    ## 48    48.05  0.312      0  2.997      1 10.343      7
    ## 49    49.03  0.306      0  2.957      1 10.258      6
    ## 50    50.03  0.320      1  2.978      4 10.313     13
    ## 51    51.05  0.313      0  2.938      1 10.245      7
    ## 52    52.05  0.307      0  2.901      1 10.183      7
    ## 53    53.05  0.320      1  3.016      9 10.405     22
    ## 54    54.05  0.315      0  3.034      4 10.472     14
    ## 55    55.05  0.327      1  3.034      3 10.500     12
    ## 56    56.05  0.321      0  2.997      1 10.455      8
    ## 57    57.05  0.316      0  2.962      1 10.412      8
    ## 58    58.07  0.310      0  2.979      4 10.454     13
    ## 59    59.05  0.305      0  2.930      0 10.364      5
    ## 60    60.05  0.316      1  2.981      6 10.491     18
    ## 61    61.05  0.328      1  2.981      3 10.516     12
    ## 62    62.05  0.322      0  2.965      2 10.492      9
    ## 63    63.07  0.317      0  2.997      5 10.529     13
    ## 64    64.07  0.328      1  2.981      2 10.489      8
    ## 65    65.07  0.338      1  2.997      4 10.558     15
    ## 66    66.07  0.333      0  3.073      8 10.701     20
    ## 67    68.07  0.338      0  3.041      2 10.593      5
    ## 68    69.07  0.333      0  3.041      3 10.627     13
    ## 69    70.07  0.328      0  3.026      2 10.576      7
    ## 70    71.07  0.324      0  3.025      3 10.553      9
    ## 71    72.07  0.319      0  2.997      1 10.518      8
    ## 72    73.07  0.328      1  3.025      5 10.593     16
    ## 73    74.08  0.324      0  3.037      4 10.596     11
    ## 74    75.07  0.320      0  3.024      2 10.551      7
    ## 75    76.07  0.316      0  3.011      2 10.557     11
    ## 76    77.08  0.311      0  3.010      3 10.508      7
    ## 77    78.08  0.307      0  3.022      4 10.540     13
    ## 78    79.07  0.316      1  3.035      4 10.586     14
    ## 79    80.08  0.312      0  3.059      5 10.601     12
    ## 80    81.08  0.308      0  3.034      1 10.508      3
    ## 81    82.08  0.305      0  3.034      3 10.514     11
    ## 82    83.07  0.301      0  3.046      4 10.594     17
    ## 83    84.08  0.309      1  3.045      3 10.632     14
    ## 84    85.08  0.306      0  3.091      7 10.731     19
    ## 85    86.08  0.302      0  3.125      6 10.757     13
    ## 86    87.08  0.299      0  3.146      5 10.783     13
    ## 87    88.08  0.295      0  3.133      2 10.797     12
    ## 88    89.08  0.292      0  3.143      4 10.810     12
    ## 89    90.08  0.289      0  3.197      8 10.912     20
    ## 90    91.08  0.285      0  3.173      1 10.869      7
    ## 91    92.08  0.282      0  3.149      1 10.838      8
    ## 92    93.10  0.279      0  3.147      3 10.827     10
    ## 93    94.08  0.287      1  3.189      7 10.905     18
    ## 94    95.08  0.284      0  3.208      5 10.906     11
    ## 95    96.08  0.281      0  3.185      1 10.876      8
    ## 96    97.10  0.278      0  3.172      2 10.875     11
    ## 97    98.10  0.285      1  3.160      2 10.866     10
    ## 98    99.10  0.283      0  3.138      1 10.817      6
    ## 99   100.10  0.280      0  3.147      4 10.819     11
    ## 100  101.10  0.287      1  3.155      4 10.851     14
    ## 101  102.08  0.284      0  3.144      2 10.834      9
    ## 102  103.10  0.281      0  3.152      4 10.854     13
    ## 103  104.10  0.279      0  3.151      3 10.826      8
    ## 104  105.10  0.285      1  3.178      6 10.875     16
    ## 105  106.10  0.302      2  3.205      6 10.943     18
    ## 106  107.12  0.299      0  3.211      4 10.969     14
    ## 107  108.10  0.305      1  3.219      4 10.999     14
    ## 108  109.10  0.302      0  3.226      4 11.017     13
    ## 109  110.10  0.318      2  3.233      4 11.063     16
    ## 110  111.10  0.324      1  3.267      7 11.098     15
    ## 111  112.12  0.330      1  3.282      5 11.149     17
    ## 112  113.12  0.327      0  3.271      2 11.130      9
    ## 113  114.10  0.324      0  3.287      5 11.192     18
    ## 114  115.10  0.321      0  3.258      0 11.129      4
    ## 115  116.12  0.319      0  3.238      1 11.066      4
    ## 116  117.12  0.316      0  3.270      7 11.126     18
    ## 117  118.12  0.322      1  3.268      3 11.158     15
    ## 118  119.12  0.319      0  3.291      6 11.216     18
    ## 119  120.12  0.333      2  3.263      0 11.181      7
    ## 120  121.12  0.330      0  3.261      3 11.196     13
    ## 121  122.12  0.328      0  3.259      3 11.178      9
    ## 122  123.12  0.325      0  3.281      6 11.193     13
    ## 123  124.12  0.322      0  3.295      5 11.231     16
    ## 124  125.12  0.320      0  3.277      1 11.198      7
    ## 125  126.13  0.317      0  3.266      2 11.195     11
    ## 126  127.13  0.315      0  3.256      2 11.169      8
    ## 127  128.12  0.312      0  3.270      5 11.185     13
    ## 128  129.12  0.310      0  3.284      5 11.207     14
    ## 129  130.12  0.307      0  3.266      1 11.159      5
    ## 130  131.13  0.305      0  3.279      5 11.202     17
    ## 131  132.13  0.303      0  3.269      2 11.201     11
    ## 132  133.15  0.300      0  3.267      3 11.205     12
    ## 133  134.15  0.298      0  3.302      8 11.249     17
    ## 134  135.13  0.303      1  3.293      2 11.241     10
    ## 135  136.13  0.301      0  3.298      4 11.254     13
    ## 136  137.13  0.299      0  3.281      1 11.215      6
    ## 137  138.15  0.297      0  3.272      2 11.198      9
    ## 138  139.15  0.295      0  3.277      4 11.204     12
    ## 139  140.15  0.293      0  3.282      4 11.224     14
    ## 140  141.13  0.291      0  3.288      4 11.245     14
    ## 141  142.15  0.302      2  3.285      3 11.263     14
    ## 142  144.15  0.305      0  3.260      0 11.280     11

### process the results of sample measurements

`process_ra()` takes the output of `read_ra()` and returns values that
can be derived solely from the data in one measurement result file.

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
`summarise_blank()`, `process_ra()`, as well as additional metadata to
return more derived values. With the argument `merged.output = TRUE`
(the default) the new values will be added to the output of
`process_ra()` (which then could be overwritten; or the functions could
be nested).

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

# example with a single sample

We use the blank and efficiency values created above. And we add two
required metadata (will be done differently later).

``` r
sampling.time <- as.POSIXct("2021-06-05 09:52:00")
filtration_volume_L <- 200.5
```

Two count measurements of one sample are (generally) needed for a
result. Here we load and process the values “manually” but this will
change later.

``` r
# count 1
c1 <- read_ra("data/test_case1/samples/050621_1grey_St3.txt", detectors = detec, date.format = datef)
c1 <- process_ra(c1)
c1 <- mutate_ra(eff = eff, blk = blk, pro = c1, filtration_volume_L = filtration_volume_L)

# count 2
c2 <- read_ra("data/test_case1/samples/130621_green_St3_2.txt", detectors = detec, date.format = datef)
c2 <- process_ra(c2)
c2 <- mutate_ra(eff = eff, blk = blk, pro = c2, filtration_volume_L = filtration_volume_L)
```

To correct for the ingrowth of decaying 228Th we estimate the amount of
228Th on the fiber using `onFiber_228Th` (the name is pretty bad and
I’ll change that).

``` r
onFiber228Th <- onFiber_228Th(midpoint.1 = c1$midpoint, 
                              midpoint.2 = c2$midpoint, 
                              dpm.220per100L.1 = c1$dpm.220per100L,
                              dpm.220per100L.2 = c2$dpm.220per100L)
onFiber228Th
```

    ## [1] 10.86755

The results, can then be calculated from the processed values of the
first measurement/count using `results_Ra()`.

``` r
results <- results_Ra(count1 = c1, 
                      sampling.time = sampling.time, 
                      onFiber228Th = onFiber228Th, 
                      estimate.227Ac = 0.05)
results
```

    ##   Ra224.DPMper100L err.Ra224.DPMper100L Ra223.DPMper100L err.Ra223.DPMper100L
    ## 1         8.891804            0.6255243          0.78359            0.1720034

Relevant metadata can easily be added.

``` r
results$file <- c1$file
results$sampling.time <- sampling.time
results
```

    ##   Ra224.DPMper100L err.Ra224.DPMper100L Ra223.DPMper100L err.Ra223.DPMper100L
    ## 1         8.891804            0.6255243          0.78359            0.1720034
    ##                   file       sampling.time
    ## 1 050621_1grey_St3.txt 2021-06-05 09:52:00

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
