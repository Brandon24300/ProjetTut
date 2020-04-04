server <- function(input, output, session) {
  
  observeEvent(input$search, {
    session$sendCustomMessage(type = 'testmessage',
                              message = 'Thank you for clicking')
  })
  
  output$plot <- renderPlot({
    plot(iris)
  })
  
  output$summary <- renderPrint({
    summary(iris)
  })
  
  output$table <- DT::renderDataTable({
    DT::datatable(iris)
  })
}