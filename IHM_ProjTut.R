source("projettut//util.R")
packages <- c("shiny", "stringr", "lattice")
installPackages(packages)
library(shiny)
library(stringr)
library(lattice)
#trellis.par.set(sp.theme()) # sets bpy.colors()

ui <- fluidPage(

  titlePanel(textOutput("title_panel")),
  sidebarLayout(
    sidebarPanel(
      selectInput("varCarte", 
                  label = h3("Type Carte"), 
                  choices = list("Départementale"), 
                  selected = "Régionale"),
      
      selectInput("varElection", 
                  label = h3("Type Election"), 
                  choices = list("Présidentielle"), 
                  selected = "Présidentielle"),
      
      selectInput("varAnnee",
                  label = h3("Année"), 
                  choices = list("2002"), 
                  selected = "2002"),
      
      selectInput("varTypeData",
                  label = h3("Stats"), 
                  choices = list("Inscrits",
                              "Abstentions",
                              "Votants",
                              "Blancs.et.nuls",
                              "Exprimés"),
                  selected = "Inscrits"),
      
      submitButton("Rechercher"),
      actionButton("reset","Effacer")
    ),
    
    mainPanel(
      textOutput("selected_var"),
      plotOutput("carte_Type_Data")
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  
  #output$selected_var <- renderText({ 
    #paste("You have selected", c(input$varCarte, input$varElection, input$varAnnee))
    #})
  
  output$title_panel <- renderText({ 
    titleAdapt(input)
  })
  
  observeEvent(input$reset, {
    output$carte_Type_Data <- NULL
  })
  
  
  output$carte_Type_Data <- renderPlot({
    #concordance <- resPresidRegion2002[idx, input$varTypeData]
    #print(concordance);print(input$varTypeData)
    createMap(input$varTypeData)
  })
  
  # Initialisation des bases
  baseElec <- data.frame(read.csv("projettut//presidDpt2002.csv", header=TRUE, sep=";"))
  formes <- getData(name="GADM", country="FRA", level=2)
  idx <- match(str_to_upper(Unaccent(formes$NAME_2)), baseElec[,2])
  formes$Inscrits <- baseElec[idx, "Inscrits"]
  formes$Abstentions <- baseElec[idx, "Abstentions"]
  formes$Votants <- baseElec[idx, "Votants"]
  formes$Blancs.et.nuls <- baseElec[idx, "Blancs.et.nuls"]
  formes$Exprimés <- baseElec[idx, "Exprimés"]
  
  createMap <- function(input){
   
    couleurs <- colorRampPalette(c('white','blue'))
    spplot(formes, input, col.regions=couleurs(16),  main=list(label="test",cex=.8))
 
  }

  titleAdapt <- function(input){
    titlePattern <- "Election %s en %s"
    titlePanel <- sprintf(titlePattern, input$varElection, input$varAnnee)
    
    return(titlePanel)
  }
  
  
  output$test_carte <- renderLeaflet({
    mapFr = map("france", fill = TRUE, plot = FALSE)
    leaflet(data = mapFr) %>% addTiles() %>%
      addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)
  })
  
}

# Run the app ----
shinyApp(ui = ui, server = server)

