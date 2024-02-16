library(tidyverse)

# temp_clean_data <- function() {
# D1_INF_OW_R1
# Day1_Infected_OW_Repeat1

wide <- matrix(runif(960, 50, 100), nrow = 10, ncol = 48) %>% 
  as.data.frame()
colnames(wide) <- c("D1_CTRL_OW_R1", "D1_CTRL_OW_R2", "D1_CTRL_OW_R3",
                 "D1_CTRL_BALF_R1", "D1_CTRL_BALF_R2", "D1_CTRL_BALF_R3",
                 "D1_INF_OW_R1", "D1_INF_OW_R2", "D1_INF_OW_R3",
                 "D1_INF_BALF_R1", "D1_INF_BALF_R2", "D1_INF_BALF_R3",
                 "D3_CTRL_OW_R1", "D3_CTRL_OW_R2", "D3_CTRL_OW_R3",
                 "D3_CTRL_BALF_R1", "D3_CTRL_BALF_R2", "D3_CTRL_BALF_R3",
                 "D3_INF_OW_R1", "D3_INF_OW_R2", "D3_INF_OW_R3",
                 "D3_INF_BALF_R1", "D3_INF_BALF_R2", "D3_INF_BALF_R3",
                 "D6_CTRL_OW_R1", "D6_CTRL_OW_R2", "D6_CTRL_OW_R3",
                 "D6_CTRL_BALF_R1", "D6_CTRL_BALF_R2", "D6_CTRL_BALF_R3",
                 "D6_INF_OW_R1", "D6_INF_OW_R2", "D6_INF_OW_R3",
                 "D6_INF_BALF_R1", "D6_INF_BALF_R2", "D6_INF_BALF_R3",
                 "D10_CTRL_OW_R1", "D10_CTRL_OW_R2", "D10_CTRL_OW_R3",
                 "D10_CTRL_BALF_R1", "D10_CTRL_BALF_R2", "D10_CTRL_BALF_R3",
                 "D10_INF_OW_R1", "D10_INF_OW_R2", "D10_INF_OW_R3",
                 "D10_INF_BALF_R1", "D10_INF_BALF_R2", "D10_INF_BALF_R3")
rownames(wide) <- round(runif(10, 1000, 100000))
wide <- rownames_to_column(wide, var = "organism")
# }                 

# REGEX separates off the second statement
long <- wide %>% 
  pivot_longer(-organism,
               names_to = c(".value", "repeat"),
               names_pattern = "(D\\d+_[A-Z]+_[A-Z]+)_R(\\d+)" # make repeat column (1-3)
  ) %>% 
  pivot_longer(-c(organism, `repeat`),
               names_to = c(".value", "location"),
               names_pattern = "(D\\d+_[A-Z]+)_([A-Z]+)" # make location column (OW/BALF)
  ) %>% 
  pivot_longer(-c(organism, `repeat`, location),
               names_to = c(".value", "type"),
               names_pattern = "(D\\d+)_([A-Z]+)"  # make type column (CTRL/INF)
  ) %>% 
  pivot_longer(-c(organism, `repeat`, location, type),
               names_to = "day"  # make day column (1, 3, 6, 10)
  ) %>% 
  rename("abundance" = value)

