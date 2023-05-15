Rrrn
================
David Kaiser

# Rrrn

R toolbox for processing of Radium data.

## read data from machine output file

`read_ra()` returns a list with all the content of the file

``` r
read_ra(file = "data/AL557/Count1/050621_1grey_St10_blank.txt")
```

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

## get summaries of blank values and detector efficiency

`summarise_blank()` and `summarise_efficiency()` take a list of file
names, call `identify_type()` to identify blanks and standards,
respectively, call `read_ra()` to read the results, and return a summary
when `summarise = TRUE` (the default), or a table of all values if
`summarise = FALSE`.

``` r
files <- list.files("data/AL557/", recursive = TRUE, full.names = TRUE, pattern = ".txt$")
summarise_blank(files)
```

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

``` r
summarise_efficiency(files)
```

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

``` r
calculate_efficiency(Ra = read_ra("data/AL557/Standards/050621_1orange_223Rastandard.txt"))
```

    ##                           filename         type isotope detector    eff.220
    ## 1 050621_1orange_223Rastandard.txt 223_standard     223   orange 0.02040784
    ##     eff.219
    ## 1 0.1238499

## process the results of sample measurements

`process_ra()` takes the output of `read_ra()` and returns values that
can be derived solely from the data in one measurement result file.

``` r
t( process_ra(read_ra("data/AL557/Count1/050621_1grey_St3.txt")) ) # transpose for better readability here
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

`final_ra()` takes the output of `summarise_efficiency()`,
`summarise_blank()`, `process_ra()`, as well as additional metadata to
return more derived values.

``` r
t( final_ra(eff = summarise_efficiency(list.files("data/AL557/Standards/", full.names = TRUE)), # transpose for better readability here
            blk = summarise_blank(list.files("data/AL557/Count1/", full.names = TRUE)),
            pro = process_ra(read_ra(file = "data/AL557/Count1/050621_1grey_St3.txt")),
            filtration_volume_L <- 200) )
```

    ## some efficiencies have been calculated with fewer than 3 standard values

    ## some blank summaries have been calculated with fewer than 3 values

    ##                    [,1]                  
    ## file               "050621_1grey_St3.txt"
    ## effic              "9.133376e-05"        
    ## final.220          "2.595914"            
    ## err.final.220      "0.1601756"           
    ## dpm.220            "33.13582"            
    ## err.dpm.220        "2.103475"            
    ## dpm.220per100L     "16.56791"            
    ## err.dpm.220per100L "1.16327"

# next

- reading meta data
- finding, sorting and combing multiple measurements (count x) of one
  sample
- workflow optimization
- code clean-up
  - get rid of unnecessary ()
  - remove objects not needed downstream
