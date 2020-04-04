source("util.R")
source("server.R")
packages <- c("shiny", "stringr", "lattice", "markdown")
installPackages(packages)
library(shiny)
library(stringr)
library(lattice)
library(markdown)
page <- navbarPage("Navbar!",
           tabPanel("Plot",
                    sidebarLayout(
                      sidebarPanel(
                        selectInput("varCarte", 
                                    label = h3("Type Carte"), 
                                    choices = list("D?partementale"), 
                                    selected = "R?gionale"),
                        
                        selectInput("varElection", 
                                    label = h3("Type Election"), 
                                    choices = list("Pr?sidentielle"), 
                                    selected = "Pr?sidentielle"),
                        
                        selectInput("varAnnee",
                                    label = h3("Ann?e"), 
                                    choices = list("2002"), 
                                    selected = "2002"),
                        
                        selectInput("varTypeData",
                                    label = h3("Stats"), 
                                    choices = list("Inscrits",
                                                   "Abstentions",
                                                   "Votants",
                                                   "Blancs.et.nuls",
                                                   "Exprim?s"),
                                    selected = "Inscrits"),
                        
                        actionButton("search", "Rechercher"),
                        actionButton("reset","Effacer")
                      ),
                      mainPanel(
                        plotOutput("plot")
                      )
                    )
           ),
           tabPanel("Summary",
                    verbatimTextOutput("summary")
           ),
           navbarMenu("More",
                      tabPanel("Table",
                               DT::dataTableOutput("table")
                      ),
                      tabPanel("About",
                               fluidRow(
                              
                               )
                      )
           )
)

shinyApp(ui = page, server = server)
