# Load the required dataset and packages
source(here::here("scripts/set-up.R"))

# Define the UI for the application
bootstrapPage(
  theme = bs_theme(
    version = 5,
    primary = "#F72732",
    "input-border-color" = "#EA80FC"
  ),
  # Insert CSS styles
  tags$style(HTML("
      .img-container {
  width: auto;
    height: auto;
    position: absolute;
    top: 2px;
    bottom: 2px;
    left: 2px;
    right: 2px;
    width: 1,
    margin: auto;
    }
      h2 {
        font-family: 'Yusei Magic', sans-serif;
      }")),
  header = tags$div(class="header", checked=NA,
                    tags$p(tags$b("Public Federal Budget"))), 
  page_fillable(collapsible = FALSE,
                id="nav",
                windowTitle = "Budget Follow-up",
                layout_sidebar(
                  sidebar =  sidebar(
                    selectInput(
                      "period", label = strong("Fiscal Year / Estimates and Expenditures"), 
                      choices = list(
                        "2020-21 Expenditures",
                        "2021-22 Estimates To Date",
                        "2021-22 Main Estimates",
                        "2022-23 Main Estimates"
                      ), 
                      selected = "2022-23 Main Estimates"
                    ),
                    selectInput("amount_format", label = strong("Amount format"), 
                                choices = list(
                                  "Billions of dollars",
                                  "Millions of dollars",
                                  "Thousands of dollars",
                                  "Dollars"
                                ), 
                                selected = "Millions of dollars"
                    ),
                    tags$div(class="header", checked = NA,
                             tags$p(strong("Source"))),
                    tags$div(class="header", checked = NA,
                             tags$a(href="https://open.canada.ca/data/en/dataset/a81099a5-f73e-4c92-ba14-0603a00d40df",
                                    "Treasury Board of Canada Secretariat. Estimates 2022-23 - Open Government Portal. Accessed 12 Nov. 2023.")),
                    tags$br(),
                    tags$div(class="header", checked = NA,
                             tags$p(strong("Note"))),
                    tags$div(class="header", checked = NA,
                             tags$p("The treemap does not display negative balances."))
                  ),
                  tabPanel("",
                           
                           layout_columns(
                             column(
                               width = 12, 
                               highchartOutput("plot_admin",
                                               height = "740")
                             ),
                             column(
                               width = 12, 
                               card(full_screen = TRUE,
                                    card_header(fillable = FALSE,
                                                "Summary table           ",
                                                downloadButton("download_table",
                                                               "Download",
                                                               icon = icon("save"),
                                                               align="right")),
                                    card_body(
                                      height = "680", 
                                      tableOutput(outputId = "tb_clean")
                                    ))
                               
                             ))
                  )
                )
  )
)





