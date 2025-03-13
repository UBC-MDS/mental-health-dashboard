library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(tidyr)
library(leaflet)
library(DT)

# Load data from local files
mental_health_data <- read.csv("../data/raw/mental_health_data.csv")
country_coords <- read.csv("../data/raw/country_coords.csv")

# Rename columns for easier use
colnames(mental_health_data) <- gsub("\\.+", "_", colnames(mental_health_data))

# Reshape data: Convert wide format to long format for age groups
long_data <- mental_health_data |> 
  pivot_longer(
    cols = starts_with("Suicide_rate"),
    names_to = "Age_Sex",
    values_to = "Suicide_Rate"
  ) |> 
  mutate(
    Age = gsub("Suicide_rate_|_Male|_Female|_Both_sexes", "", Age_Sex),
    Sex = case_when(
      grepl("Male", Age_Sex) ~ "Male",
      grepl("Female", Age_Sex) ~ "Female",
      grepl("Both_sexes", Age_Sex) ~ "Both Sexes"
    )
  ) |> 
  select(Entity, Year, Age, Sex, Suicide_Rate) |> 
  filter(!is.na(Suicide_Rate))

# Ensure country names match (rename country column)
country_coords <- country_coords |> 
  rename(Entity = Country, latitude = Latitude..average., longitude = Longitude..average.)

# UI
ui <- dashboardPage(
  dashboardHeader(title = "WHO Mental Health Dashboard"),
  dashboardSidebar(
    selectInput("countries", "Select Countries:", 
                choices = unique(long_data$Entity), 
                selected = c("United States"), multiple = TRUE),
    sliderInput("year", "Select Year:", 
                min = min(long_data$Year), 
                max = max(long_data$Year), 
                value = max(long_data$Year), 
                step = 1, sep = ""),
    selectInput("sex", "Select Sex:", 
                choices = unique(long_data$Sex), 
                selected = "Both Sexes", multiple = TRUE)
  ),
  dashboardBody(
    fluidRow(
      box(title = "Suicide Rates by Age Group", status = "primary", solidHeader = TRUE, width = 6,
          plotOutput("suicide_plot")),
      box(title = "Country Location (Map)", status = "info", solidHeader = TRUE, width = 6,
          leafletOutput("map"))
    ),
    fluidRow(
      box(title = "Filtered Data", status = "primary", solidHeader = TRUE, width = 12,
          DTOutput("filtered_table"),
          actionButton("load_more", "Load More"))
    )
  )
)

#' Server Function for Suicide Rates Dashboard
#'
#' Manages reactive data filtering, rendering of data tables, visualizations, and an interactive Leaflet map for suicide rate analysis by age, sex, and country.
#'
#' @param input Shiny input object containing selections for country, year, and sex.
#' @param output Shiny output object to send rendered tables, plots, and maps to UI.
#' @param session Shiny session object for maintaining reactive context.
#'
#' @return No explicit return value; Shiny outputs are rendered reactively:
#' \describe{
#'   \item{filtered_table}{DT DataTable of filtered suicide rate data.}
#'   \item{suicide_plot}{Bar plot visualization of suicide rates by age group and sex.}
#'   \item{map}{Leaflet map visualizing country-level average suicide rates with interactive markers.}
#' }
#'
#' @export
#'
#' @examples
#' server <- function(input, output, session) {
#'   # Call this function within the Shiny app UI definition
#' }
server <- function(input, output, session) {
  
  # Reactive dataset filtered by country, year, and sex
  filtered_data <- reactive({
    long_data  |> 
      filter(Entity %in% input$countries, Year == input$year, Sex %in% input$sex)
  })
  
  # Reactive tracker for table rows
  rows_to_show <- reactiveVal(10)
  
  observeEvent(input$load_more, {
    rows_to_show(rows_to_show() + 10)
  })
  
  # Render filtered table
  output$filtered_table <- renderDT({
    datatable(filtered_data()[1:rows_to_show(), ], options = list(pageLength = 10, searching = FALSE))
  })
  
  # Render bar plot
  output$suicide_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = Age, y = Suicide_Rate, fill = Sex)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(title = paste("Suicide Rates for", paste(input$countries, collapse = ", "), "in", input$year, "for", paste(input$sex, collapse = ", ")),
           x = "Age Group", y = "Suicide Rate per 100,000") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Render Leaflet map with suicide rate information in the tooltip
  output$map <- renderLeaflet({
    coords <- filtered_data() |> 
      inner_join(country_coords, by = "Entity") |> 
      group_by(Entity, latitude, longitude) |> 
      summarize(
        Avg_Suicide_Rate = mean(Suicide_Rate, na.rm = TRUE),
        .groups = "drop"
      )
    
    leaflet() |> 
      addTiles() |> 
      setView(lng = mean(coords$longitude, na.rm = TRUE), lat = mean(coords$latitude, na.rm = TRUE), zoom = 2) |> 
      addCircleMarkers(
        data = coords, 
        lng = ~longitude, lat = ~latitude, 
        popup = ~paste0("<b>", Entity, "</b><br>",
                        "Avg. Suicide Rate: ", round(Avg_Suicide_Rate, 2), " per 100,000"),
        label = ~paste(Entity, ": ", round(Avg_Suicide_Rate, 2), " per 100,000"),
        radius = 6, 
        color = "red", 
        fillOpacity = 0.7
      )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
