######### SOLUTION #########

.rs.restartR()
library(data.table)

stocks <- fread("../DiamondHandsProject/Stocks_1996-01-01_to_2021-01-01.csv")
#timefread <- system.time(fread("../DiamondHandsProject/Stocks_1996-01-01_to_2021-01-01.csv"))
#timefread

##### Copy the original dataset #####
library(tidyverse)
stockstest <- stocks

### There are some columns in the dataset which have to be removed, starting with "Date" and "Unnamed" ###

deletecol <- grep("Date", colnames(stockstest[,5:ncol(stockstest)]))
deletecol <- append(deletecol, grep("Unnamed", colnames(stockstest[,5:ncol(stockstest)])), after = length(deletecol))
deletecol <- deletecol + 4 #Becasue we did not delete any of the first 4 columns, we have to add 4
deletecol <- sort(deletecol, decreasing = TRUE) #have to start removing columns backwards, so the colunmnumbers don't change
delcolname <- colnames(stockstest)
j <- 1
delcolname2 <- vector(mode="character", length=length(deletecol)) #this vector will contain all the columns to remove
for (i in deletecol) {
  delcolname2[j] <- delcolname[deletecol[j[1]]]
  j <- j+1
}
delcolname2
library(dplyr)
colnames(stockstest)[2] <- "Number_1" #This column can be removed, but I left it in - TBD
colnames(stockstest)[3] <- "Number_2" #This column can be removed, but I left it in - TBD
colnames(stockstest)[4] <- "Date_stock" #had to rename it so it doesn't get removed
stockstest <- stockstest %>% select(-all_of(delcolname2)) #this line removes the columns which had to be deleted

##### Remove weekends #####

stockstest$Date_stock <- gsub(stockstest$Date_stock,pattern=" 00:00:00",replacement="",fixed=T)
stockstest$Date_stock <- as.Date(stockstest$Date_stock, format = "%Y-%m-%d")
days  <-  weekdays(stockstest$Date_stock) #for some reason it uses the Hungarian name of days, szombat = Saturday, vasárnap = Sunday
dat1  <-  tibble(stockstest, days)
stockweek <- with(dat1, subset(stockstest, days !=  "szombat"  & days != "vasárnap"  ))

##### Replace the NAs of the first row with 0s #####

stockstest2 <- stockweek[1,]
stockstest2[is.na(stockstest2)] <- 0
set(stockweek, 1L, names(stockweek), as.list(stockstest2))

###### Replace NAs with previous available price #####

install.packages("zoo") 
library("zoo")
memory.limit(20000) #had to allocate more memory
cleandata <- na.locf(stockweek[,1:ncol(stockweek)])

######


save(cleandata, file = "stocks_clean.RData")
