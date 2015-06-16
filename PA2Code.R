#Set data path
dataPath <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
fileName <- "StormData.csv.bz2"
#Download the file
download.file(url = dataPath, destfile = fileName, method = "auto")

#Extract bz2 file to a dataframe
dataInitial <- read.csv(bzfile(fileName))


library(dplyr)

library(lubridate)

#Transform date
dataInitial$date <- as.Date(dataInitial$BGN_DATE, format = "%m/%d/%Y")
head(dataInitial)
dataInitial$year <- year(dataInitial$date)
summary(dataInitial$year>=1996)
sum(!dataInitial$year>=1996)/nrow(dataInitial)

#Filter by year
dataYearProcessed <- dataInitial[dataInitial$year>=1996,]

dataStatesProcessed <- dataYearProcessed[dataYearProcessed$STATE %in% state.abb,]

summary(dataYearProcessed$STATE %in% state.abb)
percentDataRemStates <- sum(!dataYearProcessed$STATE %in% state.abb)/nrow(dataYearProcessed)

summary(dataStatesProcessed$EVENT)

dataStatesProcessed %>% 
        select(EVTYPE, FATALITIES, INJURIES, PROPDMG, PROPDMGEXP, CROPDMG, CROPDMGEXP) -> dataPreprocess

dataAgregateFatalities <- with(dataPreprocess, aggregate(FATALITIES, list(EVTYPE), sum))
dataAgregateFatalities <- rename(dataAgregateFatalities, EVTYPE = Group.1, FATALITIES = x)
plot(arrange(dataAgregateFatalities,desc(FATALITIES))[1:20,], type="hist")


dataAgregateINJURIES <- with(dataPreprocess, aggregate(INJURIES, list(EVTYPE), sum))
dataAgregateINJURIES <- rename(dataAgregateINJURIES, EVTYPE = Group.1, INJURIES = x)
arrange(dataAgregateINJURIES, desc(INJURIES))[1:20,]





dataGrouped %>% 
        mutate(multiPROPDM = ifelse(PROPDMGEXP == 'B', 10^9, 
                                    ifelse(PROPDMGEXP == 'M', 10^6, 
                                           ifelse(PROPDMGEXP == 'K', 10^3, 
                                                  ifelse(PROPDMGEXP == 'H', 100, 1))))) %>%
        mutate(totalPROPDMG = as.numeric(multiPROPDM) * as.numeric(PROPDMG)) -> dataTreated



summary(dataInitial$EVTYPE)
summary(dataInitial$PROPDMG)
summary(dataInitial$PROPDMGEXP)


summary(dataGrouped)

#FATALITIES INJURIES
#PROPDMG PROPDMGEXP CROPDMG CROPDMGEXP