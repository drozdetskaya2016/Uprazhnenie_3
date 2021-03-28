library('shiny')
library('RCurl')

#df.comtrade <- read.csv('./new_un_comtrade.csv', header = TRUE, sep = ',')

URL <- 'https://raw.githubusercontent.com/drozdetskaya2016/Uprazhnenie_3/main/data/new_un_comtrade.csv'

df.comtrade <- read.csv(URL)

# Торговые потоки, переменная для фильтра фрейма
trade.flow <- as.character(unique(df.comtrade$Trade.Flow))
names(trade.flow) <- trade.flow
trade.flow <- as.list(trade.flow)

shinyUI(
  pageWithSidebar(
    headerPanel("Коробчатые диаграммы разброса суммарной стоимости поставок по фактору «вхождение страны-поставщика в объединение»"),
    sidebarPanel(
      # Выбор кода продукции
      selectInput('sp.to.plot',
                  'Выберите код продукта',
                  list('Огурцы и корнишоны' = '707',
                       'Бобовые овощи; очищенные/неочищенные' = '708',
                       'Овощи; не включенные в другие группы в 07' = '709',
                       'Овощи (сырые или приготоволенные на пару или в воде); замороженные' = '710',
                       'Предварительно консервированные овощи' = '711',
                       'Овощи сушеные; целые, нарезанные и др.' = '712',
                       'Овощи зернобобовые; очищенные, с кожурой или без, сушеные' = '713',
                       'Маниок, маранта, салеп, топинамбур, сладкий картофель и др.' = '714'),
                  selected = '707'),
      # Выбор экпорт/импорт
      selectInput('trade.to.plot',
                  'Выберите торговый поток:',
                  trade.flow),
      # Период, по годам
      sliderInput('year.range', 'Года:',
                  min = 2010, max = 2020, value = c(2010, 2020),
                  width = '100%', sep = '')
    ),
    mainPanel(
      plotOutput('sp.ggplot')
    )
  )
)