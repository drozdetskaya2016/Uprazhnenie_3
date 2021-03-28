library('shiny')               # создание интерактивных приложений
library('lattice')             # графики lattice
library('data.table')          # работаем с объектами "таблица данных"
library('ggplot2')             # графики ggplot2
library('dplyr')               # трансформации данных
library('lubridate')           # работа с датами, ceiling_date()
library('zoo')                 # работа с датами, as.yearmon()

# функция, реализующая API (источник: UN COMTRADE)
source("https://raw.githubusercontent.com/aksyuk/R-data/master/API/comtrade_API.R")

# Получаем данные с UN COMTRADE за период 2010-2020 года, по следующим кодам
code = c('0707', '0708', '0709', '0710', '0711', '0712', '0713', '0714')
df.comtrade = data.frame()
for (i in code){
  for (j in 2010:2020){
    Sys.sleep(5)
    s1 <- get.Comtrade(r = 'all', p = 643,
                       ps = as.character(j), freq = "M",
                       cc = i, fmt = 'csv')
    df.comtrade <- rbind(df.comtrade, s1$data)
  }
}

# Загружаем полученные данные в файл, чтобы не выгружать их в дальнейшем заново
file.name <- paste('./data/un_comtrade.csv', sep = '')
write.csv(df.comtrade, file.name, row.names = FALSE)

write(paste('Файл',
            paste('un_comtrade.csv', sep = ''),
            'загружен', Sys.time()), file = './data/download.log', append=TRUE)

# Загружаем данные из файла
df.comtrade <- read.csv('./data/un_comtrade.csv', header = T, sep = ',')

# Оставляем  только те столбцы, которые понядобятся в дальше
df.comtrade <- df.comtrade[, c(2, 8, 10, 22, 32)]

df.comtrade

# СНГ без Белоруссии и Казахстана
group.1 = c('Armenia', 'Kyrgyzstan', 'Azerbaijan', 'Rep. of Moldova', 'Tajikistan', 'Turkmenistan', 'Uzbekistan', 'Ukraine')
# Таможенный союз России, Белоруссии и Казахстана
group.2 = c('Russian Federation', 'Belarus', 'Kazakhstan')

new.df.comtrade <- data.frame(Year = numeric(), Trade.Flow = character(), Reporter = character(),
                              Trade.Value..US.. = numeric(), Group = character())

new.df.comtrade <- rbind(new.df.comtrade, cbind(df.comtrade[df.comtrade$Reporter %in% group.1, ], data.frame(Group = 'СНГ без Белоруссии и Казахстана')))
new.df.comtrade <- rbind(new.df.comtrade, cbind(df.comtrade[df.comtrade$Reporter %in% group.2, ], data.frame(Group = 'Таможенный союз Рус, Каз, Бел')))
new.df.comtrade <- rbind(new.df.comtrade, cbind(df.comtrade[!(df.comtrade$Reporter %in% group.1) & !(df.comtrade$Reporter %in% group.2), ],
                                                data.frame(Group = 'Остальные страны')))

new.df.comtrade

new.df.comtrade <- new.df.comtrade[new.df.comtrade$Trade.Value..US.. < 100000, ]

file.name <- paste('./data/new_un_comtrade.csv', sep = '')
write.csv(new.df.comtrade, file.name, row.names = FALSE)

new.df.comtrade <- read.csv('./data/new_un_comtrade.csv', header = T, sep = ',')

# Код продукта, переменная для фильтра фрейма
commodity.code <- as.character(unique(new.df.comtrade$Commodity.Code))
names(commodity.code) <- commodity.code
commodity.code <- as.list(commodity.code)
commodity.code

# Торговые потоки, переменная для фильтра фрейма
trade.flow <- as.character(unique(new.df.comtrade$Trade.Flow))
names(trade.flow) <- trade.flow
trade.flow <- as.list(trade.flow)
trade.flow


df <- new.df.comtrade[new.df.comtrade$Commodity.Code == commodity.code[2] &
                        new.df.comtrade$Trade.Flow == trade.flow[1], ]
df

gp <- ggplot(data = df, aes(x = df$Trade.Value..US.., y = Group, group = Group, color = Group))
gp <- gp + geom_boxplot() + coord_flip() + scale_color_manual(values = c('red', 'blue', 'green'),
                                                              name = 'Страны-поставщики')
gp <- gp + labs(title = 'Коробчатые диаграммы разброса суммарной стоимости поставок по фактору "вхождение страны-поставщика в объединение"',
                x = 'Сумма стоимости поставок', y = 'Страны')
gp

# Запуск приложения
runApp('./comtrade_app', launch.browser = TRUE,
       display.mode = 'showcase')
