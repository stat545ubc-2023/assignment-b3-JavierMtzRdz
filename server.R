# Set up ----
source(here::here("scripts/set-up.R"))


# Server 
function(input, output, session) {
  
  # Generate processed dataset -----
  prcssd_bdgt <- eventReactive(c(input$period,
                                 input$amount_format),
                               {
                                 
                                 ## Convert amount -----
                                 divider <- case_match(input$amount_format,
                                                       "Billions of dollars" ~ 1000000000,
                                                       "Millions of dollars" ~ 1000000,
                                                       "Thousands of dollars" ~ 1000,
                                                       "Dollars" ~ 1)
                                 
                                 ## Filter and convert selected amount ----
                                 
                                 cnd_bdgt_det <- cnd_bdgt %>% 
                                   filter(period == input$period) %>% 
                                   mutate(amount = amount  / divider,
                                          org_num = cur_group_id(),
                                          Description = paste0(Description, "[",
                                                               org_num, "]"),
                                          .by = Organization)
                                 
                                 return(cnd_bdgt_det)
                                 
                               })
  
  # Convert dataset to hierarchical structures -----
  det_hier <- eventReactive(c(prcssd_bdgt()),
                            { 
                              
                              data_to_hierarchical(data = prcssd_bdgt() %>% 
                                                     filter(amount > 0),
                                                   group_vars = c("Organization",
                                                                  "Description"),
                                                   size_var = amount) %>%
                                data.table::rbindlist(fill = T) %>%
                                as_tibble()
                              
                            })
  
  
  # Generate treemap ----
  
  ## Indicate base colors ------
  colors <- c("#a4243b","#ff5b59","#006d77","#2a9d8f",
              "#e9c46a","#ee5276")
  
  ## Create plot ----
  
  output$plot_admin <- renderHighchart({
    
    ### Load updates datasets -----
    data_prcssd_bdgt <- prcssd_bdgt() %>% 
      filter(amount > 0)
    data_det_hier <- det_hier()
    
    
    ### Count categories -----
    row_colors <- data_det_hier %>% 
      filter(level == 1) %>% 
      nrow()
    
    ### Assign color to every category -----
    
    set.seed(545)
    colors_plot <- (colorRampPalette(colors))(row_colors) %>% 
      sample(row_colors)
    
    colors1 <- data_prcssd_bdgt %>%
      group_by(Organization) %>%
      summarise(amount = sum(amount, na.rm = T)) %>%
      ungroup() %>%
      arrange(-amount) %>%
      select(-amount) %>%
      mutate(colors1 = colors_plot[1:max(row_number())])
    
    colors2 <- data_prcssd_bdgt %>%
      left_join(colors1,
                by = "Organization") %>%
      group_by(Organization, Description, colors1) %>%
      summarise(amount = sum(amount, na.rm = T)) %>%
      ungroup() %>%
      arrange(-amount) %>%
      group_by(colors1) %>%
      mutate(amount = amount/sum(amount, na.rm = T),
             amount = ifelse(is.nan(amount), 0, amount),
             col_adj = (-(amount/1.2)+0.4),
             colors2 = lighten(colors1,
                               col_adj)) %>% 
      ungroup() %>%
      select(-amount,
             -colors1)
    
    
    
    data_det_hier <- data_det_hier %>%
      left_join(colors1,
                by = c("name" = "Organization")) %>%
      left_join(colors2,
                by = c("name" = "Description")) %>%
      mutate(color = colors1,
             color = ifelse(is.na(color),
                            colors2,
                            color),
             color = ifelse(is.na(color),
                            colors3,
                            color),
             name = str_remove_all(name, "\\[.*\\]")) %>% 
      list_parse() %>%
      purrr::map(function(x) x[!is.na(x)])
    
    ### Include JS code to connect the plot with the table ---
    
    click_js <- JS("function(event) {Shiny.onInputChange('treemapclick', event.point.id);}")
    
    drillup_js <- JS("function(H) {
  H.wrap(H.seriesTypes.treemap.prototype, 'drillUp', function(proceed) {

    Shiny.onInputChange('treemapclick', 'drillingup', {priority: 'event'});
    // proceed
    proceed.apply(this);

  });
}(Highcharts)")
    
    
    ### Generate treemap -----
    
    hchart(data_det_hier,
           type = "treemap",
           allowDrillToNode = TRUE,
           allowPointSelect = T,
           levelIsConstant = F,
           layoutAlgorithm = "squarified",
           
           
           levels = list(
             list(
               level = 1,
               dataLabels = list (enabled = T,
                                  color = '#e8e6e3',
                                  style = list("fontSize" = "1.2em",
                                               "fontWeight" = 'bold')),
               borderWidth = 2.5
             ),
             list(
               level = 2,
               dataLabels = list (enabled = F),
               borderWidth = 1.5
             ),
             list(
               level = 3,
               dataLabels = list (enabled = F),
               borderWidth = 1
             )
           )) %>%
      hc_title(text = paste0("Government Expenditure Plan and Main Estimates Composition by Organization"),
               style = list(color = "#333333",
                            fontWeight = "bold",
                            useHTML = TRUE)) %>%
      hc_subtitle(text = paste0("<b>", input$period, 
                                "<br>",
                                input$amount_format,
                                "</b>"),
                  style = list(color = "#7f7f7f",
                               fontSize = '1.4em',
                               useHTML = TRUE)) %>%
      hc_tooltip(pointFormat = paste0("<b>{point.name}</b>:<br>
                             ",
                             "Amount",
                             ": ${point.value:,.0f}")) %>% 
      hc_plotOptions(treemap = list(events = list(click = click_js,
                                                  drillup = drillup_js)))
    
  })
  
  
  
  # Generate rules to track clicked categories ----
  clicked <- reactiveVal(tibble(name = NA, 
                                id = NA,
                                color = NA,
                                level = NA,
                                parent = NA, 
                                value = NA))
  
  observeEvent(input$treemapclick, {
    
    message(input$treemapclick)
    
    if (!is.null(input$treemapclick) &&
        input$treemapclick != "drillingup"){
      clicked(det_hier() %>%
                filter(id == input$treemapclick))
      
    }
    
    if (!is.null(input$treemapclick) &&
        input$treemapclick == "drillingup"){
      
      clicked <- clicked()
      
      
      if (clicked$level == 2) {
        
        clcd <- clicked_parent() %>%
          as_tibble()
        
        clicked(clcd)
      }
      
      if (clicked$level == 1) {
        
        clicked(tibble(name = NA,
                       id = NA,
                       color = NA,
                       level = 0,
                       parent = NA,
                       value = NA))
      }
      
    }
  })
  
  observeEvent(c(input$period),
               {
                 
                 clicked(tibble(name = NA,
                                id = NA,
                                color = NA,
                                level = 0,
                                parent = NA,
                                value = NA))
                 
               })
  
  clicked_parent <- eventReactive(clicked(),
                                  {
                                    clicked <- clicked()
                                    if (!is.null(input$treemapclick) &&
                                        input$treemapclick != "drillingup" &&
                                        clicked$level > 0){
                                      
                                      
                                      det_hier() %>%
                                        filter(id == clicked$parent)
                                      
                                    } else {
                                      return(NULL)
                                    }
                                    
                                  })
  
  
  # Generate dataset filter with ----
  table_data <- eventReactive(c(prcssd_bdgt(),
                                # clicked()
                                clicked()
  ),
  {
    
    ## Load tables and clicked categories ----
    table <- prcssd_bdgt()
    
    clicked <- clicked()
    
    clicked_parent <- clicked_parent()
    
    ## Case without previous click -----
    if (is.null(input$treemapclick)){
      table <- table %>% 
        summarise(amount = sum(amount),
                  .by = Organization)
      
      category <- "Organization"
    }
    
    ## Case with previous click -----
    if (!is.null(input$treemapclick) &&
        input$treemapclick != "drillingup"){
      
      vars_clas <- unique(c("Organization", 
                            "Description"))
      
      clicked_lev_var <- case_match(clicked$level,
                                    0 ~ NA,
                                    1 ~ "Organization", 
                                    2 ~ "Description")
      
      if(!is.null(clicked_parent)) {
        clicked_lev_par <- case_match(clicked_parent$level,
                                      1 ~ "Organization", 
                                      2 ~ "Description")
        
      }
      
      
      if (clicked$level == 0) {
        table <- table %>% 
          summarise(amount = sum(amount),
                    .by = Organization)
        
      }
      
      
      if (clicked$level == 1) {
        
        table <- table %>% 
          summarise(amount = sum(amount),
                    .by = c(Organization, Description))
        
      }
      
      if (clicked$level == 2) {
        
        
        table <- table %>% 
          summarise(amount = sum(amount),
                    .by = c(Organization, Description)) %>% 
          filter(!!rlang::sym(clicked_lev_par) == clicked_parent$name,
                 !!rlang::sym(clicked_lev_var) == clicked$name)
        
      }
      
      
    }
    
    ## Case drilling up -----
    
    if (!is.null(input$treemapclick) &&
        input$treemapclick == "drillingup"){
      
      table <- table %>% 
        summarise(amount = sum(amount),
                  .by = c(Organization))
      
      category <- "Organization"
      
    }
    
    return(table)
    
  })
  
  
  ## Generate table to be exported ------
  table_output <- eventReactive(table_data(),
                                { 
                                  tbl <- table_data() %>% 
                                    arrange(-amount) %>% 
                                    rename(Amount = amount)
                                  
                                  if("Description" %in% names(tbl)){
                                    tbl <- tbl %>% 
                                      mutate(Description = str_remove_all(Description,
                                                                          "\\[.*\\]"))
                                  }
                                  
                                  return(tbl)
                                })
  
  ## Generate exported output ------
  
  output$download_table <- downloadHandler(
    filename = function() {
      paste0("Summary-table-",
             format(now(), "%T %d/%m/%Y"),
             ".xlsx")
    },
    content = function(file){
      if (is.null(table_output())){
        return(NULL) 
      }
      
      table_output() %>% 
        write_xlsx(file)
      
    }
  )
  
  ## Generate displayed table ------
  output$tb_clean <- renderUI({
    
    table_output() %>% 
      mutate_if(is.numeric, function(x){comma(x, 
                                              accuracy = 1L)}) %>% 
      kbl() %>% 
      row_spec(0, bold = T, color = "white", background = "#000c2d", 
               align = "c", 
               extra_css = 'vertical-align: middle !important;') %>% 
      kable_styling(bootstrap_options = c("striped", "hover",
                                          "condensed", "responsive"),
                    font_size = 11
      ) %>% 
      HTML()
    
    
  })
  
  
  
}



