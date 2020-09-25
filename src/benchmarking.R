library(hermes6)
library(dplyr)

## Overview of time taken by each variation of model in hermes6 ----
## From https://healtheconomicshackathon.github.io/hermes6/articles/Benchmarking.html

function_names <- ls("package:hermes6", pattern = "markov*")

func_calls <- lapply(function_names, function(func) call(func))

output <- lapply(function_names, function(func) {
  func_call <- call(func)
  print(func_call)
  out <- system.time(eval(func_call))
  print(out)
  out["elapsed"]
})

names(output) <- function_names

output_df <- output %>%
  unlist(recursive = FALSE) %>%
  enframe()

output_df

## Generate runtime of selected models ----

df_benchmark <- bench::mark(
  base = markov_expanded(), 
  vectorisetx = markov_expanded_lapply(), 
  vectorisesmp = markov_expanded_vectorisesmp(n.states = 10, n.cycles = 100, n.samples = 25000), 
  vectorisetx_rcppcycle = markov_expanded_lapply_rcpp(), 
  parallelisesmp = markov_expanded_parallisesmp_furrr(n.states = 10, n.cycles = 100, n.samples = 25000), 
  iterations = 20, check = FALSE, memory = FALSE
)

saveRDS(df_benchmark, "df_benchmark.rds") 
