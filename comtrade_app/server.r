library('shiny')
library('dplyr')
library('data.table')
library('RCurl')
library('ggplot2')
library('lattice')
library('zoo')
library('lubridate')

#df.comtrade <- read.csv('new_un_comtrade.csv', header = TRUE, sep = ',')
URL <- 'https://raw.githubusercontent.com/drozdetskaya2016/Uprazhnenie_3/main/data/new_un_comtrade.csv'

df.comtrade <- read.csv(URL)

df.comtrade <- data.table(df.comtrade)
df.comtrade
shinyServer(function(input, output){
  DT <- reactive({
    DT <- df.comtrade[between(Year, input$year.range[1], input$year.range[2]) &
                        Commodity.Code == input$sp.to.plot &
                        Trade.Flow == input$trade.to.plot, ]
    DT <- data.table(DT)
  })
  output$sp.ggplot <- renderPlot({
    gp <- ggplot(data = DT(), aes(x = Trade.Value..US.., y = Group, group = Group, color = Group))
    gp <- gp + geom_boxplot() + coord_flip() + scale_color_manual(values = c('red', 'blue', 'green'),
                                                                  name = 'Страны-поставщики')
    gp <- gp + labs(title = 'Коробчатые диаграммы разброса суммарной стоимости поставок по фактору "вхождение страны-поставщика в объединение"',
                    x = 'Сумма стоимости поставок', y = 'Страны')
    gp
  })
})