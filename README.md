# Government Expenditure Shiny App

## Description

The Government Expenditure Shiny App provides a user-friendly interface to explore and understand the distribution of government expenditures across various organizations and descriptions.

Users can interact with the treemap to navigate through different levels of the budget hierarchy and the connected table ensures that detailed information is readily available. The dynamic data processing feature enhances the app's versatility, allowing users to customize their view of the data.

![](figures/app-example.png)

## Acknowledgment

The data used in this project is sourced from the Treasury Board of Canada Secretariat's "Estimates 2022-23," which is available on the [Open Government Portal](https://open.canada.ca/data/en/dataset/a81099a5-f73e-4c92-ba14-0603a00d40df).

## Shiny App Link

You can access the running instance of the Shiny app [here](https://javier-mtz-rd.shinyapps.io/PublicFedBudg/).

## Assignment Choice

This project was undertaken as part of **Option B: Create your own Shiny app with three features and deploy it.**

## Features

1.  **Treemap Visualization:** The app has a treemap visualization to represent the Government Expenditure Plan and Main Estimates Composition by Organization and Description. This allows users to explore the budget allocation at different levels.

2.  **Downloadable Table:** The treemap is complemented by a downloadable table that dynamically updates based on user interactions. Clicking on different segments of the treemap triggers updates in the table, providing users with detailed information about the selected organization and description. This feature facilitates data sharing, allowing users to utilize the information in other contexts.

3.  **Dynamic Data Processing:** The app includes functionality to process the dataset dynamically based on user input. Users can choose the fiscal year and format in which they want to view the expenditure amounts (e.g., Bills, millions, thousands, or dollars).

### Repo Contents

In this repository's structure, the key components include:

-   `ui.R`: This file defines how the Shiny app looks to the user.
-   `server.R`: This file manages the inner workings of the Shiny app, handling data and producing what users see.
-   `scripts`: This directory contains a script named `set-up.R`, responsible for preparing the dataset and loading necessary libraries.
-   `data`: Here, data files used by the Shiny app are stored. The `set-up.csv` file within this directory contain the prepared data necessary for the app's functionality

In detail, the repository has the following structure.

``` bash
.
|____ui.R
|____server.R
|____README.md
|____figures
| |____app-example.png
|____scripts
| |____set-up.R
|____data
| |____set-up.csv
|____.gitignore
|____expend-app.Rproj
```

## How to Run Code from This Repository

### Pre-requisites

Ensure the following R packages are installed:

``` r
install.packages("shiny")
install.packages("shinythemes")
install.packages("here")
install.packages("tidyverse")
install.packages("writexl")
install.packages("kableExtra")
install.packages("bslib")
install.packages("scales")
install.packages("colorspace")
install.packages("highcharter")
install.packages("grDevices")
```

### Steps

1.  Clone or download the repository to your local machine.

  -   Launch RStudio.
  -   Go to `File -> New Project`.
  -   Choose `Version Control`.
  -   Select `Git`.
  -   In the "Repository URL" field, paste the GitHub repository URL.
  -   Choose where to save the repository in the "Create project as a subdirectory of" field.
  -   Click `Create Project`.

2.  Open the expend-app.Rproj file in RStudio.
3.  Open ui.R and server.R files.
4.  Click the Run App button in RStudio's toolbar. This will launch the Shiny app in your default web browser, allowing you to interact with the Government Expenditure Visualization tool.
