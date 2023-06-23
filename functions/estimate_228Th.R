# Th estimate from measured values of one count, typically the first count
estimate_228Th <- function(pro # the output of process_ra()
                           ) {
  return(sqrt(pro$CPM220*pro$Runtime - pro$cc.220*pro$Runtime) / (pro$CPM220*pro$Runtime - pro$cc.220*Ra$Runtime))
}
#estimate_228Th(process_ra(read_ra("data/test_case1/050621_1grey_St3.txt")))
