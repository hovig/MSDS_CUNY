library(ggplot2)
library(dplyr)
library(shiny)

df <- read.csv('https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv')

df_grouped <- mutate_if(df, is.factor, as.character) %>%
  group_by(Year, ICD.Chapter) %>%
  summarize(nation.rate = 10^5*(sum(as.numeric(Deaths))/sum(as.numeric(Population)))) %>%
  mutate(State = "NATIONAL") %>%
  rename(Crude.Rate = nation.rate) %>%
  as.data.frame()

df_mutated <- select(df, ICD.Chapter, Year, Crude.Rate, State) %>%
  mutate_if(is.factor, as.character) %>%
  as.data.frame()

df_bind <- rbind(df_grouped,df_mutated)
df_bind$fill <- with(df_bind, ifelse(State == 'NATIONAL', 1,0))

ui <- fluidPage(
  headerPanel('CDC Mortality 1999-2010'),
  sidebarPanel(
    selectInput(inputId = "disease", label = "Choose disease", choices = unique(df$ICD.Chapter), selected = "Neoplasms"),
    selectInput(inputId = "year", label = "Choose year", choices = unique(df$Year), selected = 2010)
  ),

  mainPanel(
    plotOutput('bar'),
    verbatimTextOutput('stats')
  )
)

server <- function(input,output){
  selectedData <- reactive({
    dfSlice <- df_bind %>%
      filter(Year == input$year, ICD.Chapter == as.character(input$disease)) %>%
      transform(State = reorder(State, Crude.Rate))
  })

  output$bar <- renderPlot({
    ggplot(selectedData(),aes(x = State, y = Crude.Rate))+
      geom_bar(stat = "identity",color='black',aes(fill = factor(fill)))+
      scale_fill_manual(values = c("1" = "blue", "0" = "white"), guide= FALSE)+
      coord_flip()
  })

  output$stats <- renderPrint({
     dfSliceTier <- selectedData()
     summary(dfSliceTier$Crude.Rate)
   })
}

shinyApp(ui = ui, server = server)
