# Th estimate from measured values of one count, typically the first count
estimate_228Th <- function(Ra # the output of process_ra()
                           ) {
  return(sqrt(Ra$CPM220*Ra$Runtime - Ra$cc.220*Ra$Runtime) / (Ra$CPM220*Ra$Runtime - Ra$cc.220*Ra$Runtime))
}
#estimate_228Th(process_ra(read_ra("data/test_case1/050621_1grey_St3.txt")))
