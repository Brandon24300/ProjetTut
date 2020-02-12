library(shiny)

ui <- fluidPage(

  titlePanel(textOutput("title_panel")),
  sidebarLayout(
    sidebarPanel(
      selectInput("varCarte", 
                  label = h3("Type Carte"), 
                  choices = list("R�gionale", 
                                 "D�partementale",
                                 "Communale"), 
                  selected = "R�gionale"),
      
      selectInput("varElection", 
                  label = h3("Type Election"), 
                  choices = list("Pr�sidentielle", 
                                 "L�gislative",
                                 "Cantonnale"), 
                  selected = "Pr�sidentielle"),
      
      selectInput("varAnnee",
                  label = h3("Ann�e"), 
                  choices = list("2012", 
                                 "2013",
                                 "2014"), 
                  selected = "2012"),
      
      submitButton("Rechercher")
    ),
    
    mainPanel(
      textOutput("selected_var")
      
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  
  output$selected_var <- renderText({ 
    paste("You have selected", c(input$varCarte, input$varElection, input$varAnnee))
    })
  
  output$title_panel <- renderText({ 
    titleAdapt(input)
  })
  
  
  titleAdapt <- function(input){
    
    titlePattern <- "Election %s en %s"
    titlePanel <- sprintf(titlePattern, input$varElection, input$varAnnee)
    
    return(titlePanel)
  }
  
}

# Run the app ----
shinyApp(ui = ui, server = server)
