# Load necessary packages
library(shiny)
library(shinythemes)
library(here)
library(tidyverse)
library(writexl)
library(kableExtra)
library(bslib)
library(scales)
library(colorspace)
library(highcharter)
library(grDevices)

# Update dataset if needed
if(FALSE) {
  # Read the CSV file from the web
  cnd_bdgt <- read_csv(
    file = "https://www.canada.ca/content/dam/tbs-sct/documents/planned-government-spending/main-estimates/2022-23/organization-summary.csv",
    local = locale(encoding = "latin1")
  ) %>% 
    # Select relevant columns
    select(-`Description...6`) %>% 
    # Reshape the dataset
    pivot_longer(
      starts_with("20"),
      names_to = "period",
      values_to = "amount"
    ) %>% 
    # Rename columns
    rename(`Description` = `Description...5`) %>% 
    # Extract the year from the 'period' column
    mutate(period = str_remove_all(period, "/.*"))

  # Save the updated dataset locally
  write_csv(cnd_bdgt, here("data/set-up.csv"))
}

# Load the dataset
cnd_bdgt <- read_csv(here("data/set-up.csv"))






