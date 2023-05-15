Rrrn
================
David Kaiser

# Rrrn

R toolbox for processing of Radium data.

## read data from machine output file

`read_ra()` returns a list with all the content of the file

    ## $filename
    ## [1] "050621_1grey_St10_blank.txt"
    ## 
    ## $original.filename
    ## [1] "050621_1grey_blank4.txt"
    ## 
    ## $type
    ## [1] "blank"
    ## 
    ## $detector
    ## [1] "grey"
    ## 
    ## $start.time
    ## [1] "2021-06-05 20:37:33 CEST"
    ## 
    ## $end.time
    ## [1] "2021-06-05 20:50:40 CEST"
    ## 
    ## $count.summary
    ##       Runtime CPM219 Cnt219 CPM220 Cnt220 CPMTot CntTot
    ## value   13.12      0      0      0      0  1.525     20
    ## 
    ## $counts
    ##    Runtime CPM219 Cnt219 CPM220 Cnt220 CPMTot CntTot
    ## 1     0.98      0      0      0      0  0.000      0
    ## 2     2.00      0      0      0      0  1.000      2
    ## 3     3.00      0      0      0      0  1.000      1
    ## 4     4.00      0      0      0      0  1.500      3
    ## 5     5.00      0      0      0      0  1.600      2
    ## 6     6.02      0      0      0      0  1.330      0
    ## 7     7.00      0      0      0      0  1.429      2
    ## 8     8.00      0      0      0      0  1.500      2
    ## 9     9.00      0      0      0      0  1.444      1
    ## 10   10.00      0      0      0      0  1.600      3
    ## 11   11.00      0      0      0      0  1.636      2
    ## 12   12.02      0      0      0      0  1.664      2
    ## 13   13.02      0      0      0      0  1.536      0

files \<- list.files(“data/AL557/”, recursive = TRUE, full.names = TRUE,
pattern = “.txt\$”)

## get summaries of blank values and detector efficiency

`summarise_blank()` and `summarise_efficiency()` take a list of file
names, call `identify_type()` to identify blanks and standards,
respectively, call `read_ra()` to read the results, and return a summary
when `summarise = TRUE` (the default), or a table of all values if
`summarise = FALSE`.

    ##    detector isotope        mean         sd  n
    ## 1      blue     223 0.000000000 0.00000000  9
    ## 2     green     223 0.000000000 0.00000000  7
    ## 3      grey     223 0.000000000 0.00000000 10
    ## 4    orange     223 0.000000000 0.00000000 10
    ## 5      blue     224 0.009555556 0.01435367  9
    ## 6     green     224 0.010571429 0.01760546  7
    ## 7      grey     224 0.027000000 0.02018801 10
    ## 8    orange     224 0.007100000 0.01576529 10
    ## 9      blue  CMPTot 0.780555556 0.30197190  9
    ## 10    green  CMPTot 1.189857143 0.58627395  7
    ## 11     grey  CMPTot 0.814900000 0.42445009 10
    ## 12   orange  CMPTot 0.690500000 0.45655017 10

A warning will be printed if less than 3 values are used in a summary.

    ## some efficiencies have been calculated with fewer than 3 standard values

    ##   detector isotope       mean          sd n
    ## 1     blue     223 0.16719556          NA 1
    ## 2    green     223 0.16171887 0.025992173 2
    ## 3     grey     223 0.15970596 0.014366844 3
    ## 4   orange     223 0.15368312 0.029657118 5
    ## 5     blue     224 0.06786601 0.011661518 2
    ## 6    green     224 0.07783872          NA 1
    ## 7     grey     224 0.07834163 0.014916630 5
    ## 8   orange     224 0.07367752 0.005927695 3

`summarise_efficiency()` also calls `calculate_efficiency()` to
calculate efficiency.

    ##                           filename         type isotope detector    eff.220
    ## 1 050621_1orange_223Rastandard.txt 223_standard     223   orange 0.02040784
    ##     eff.219
    ## 1 0.1238499

## process the results of sample measurements

`process_ra()` takes the output of `read_ra()` and returns values that
can be derived solely from the data in one measurement result file.

    ##                   file detector          start.time Runtime            midpoint
    ## 1 050621_1grey_St3.txt     grey 2021-06-05 09:52:46  144.72 2021-06-05 12:17:29
    ##   CPMTot CPM219 CPM220 err.total.cpm total.counts err.220.cpm err.220.2by
    ## 1 11.284  0.304  3.262     0.2792333      1633.02   0.1501335  0.09204999
    ##      err.220 counts.220 err.219.cpm err.219.2by    err.219 counts.219    cc.220
    ## 1 0.05138956   472.0766  0.04583239   0.3015289 0.04522912   43.99488 0.6454945
    ##   err.cc.220     x    err.x      cc.219  err.cc.219        y     err.y corr.220
    ## 1 0.05582238 7.718 0.320331 0.004654953 0.001865508 8.363495 0.3251585 2.616505
    ##   err.corr.220 corr.219 err.corr.219
    ## 1    0.1601756 0.299345   0.04587034

`final_ra()` takes the output of `summarise_efficiency()`,
`summarise_blank()`, `process_ra()`, as well as additional metadata to
return more derived values.

    ## some efficiencies have been calculated with fewer than 3 standard values

    ## some blank summaries have been calculated with fewer than 3 values

    ##                   file        effic final.220 err.final.220  dpm.220
    ## 1 050621_1grey_St3.txt 9.133376e-05  2.595914     0.1601756 33.13582
    ##   err.dpm.220 dpm.220per100L err.dpm.220per100L
    ## 1    2.103475       16.56791            1.16327

# next

- reading meta data
- finding, sorting and combing multiple measurements (count x) of one
  sample
- optimizations
