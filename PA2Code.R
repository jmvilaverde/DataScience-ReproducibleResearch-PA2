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

summary(dataStatesProcessed$PROPDMGEXP)

dataStatesProcessed %>% 
        select(EVTYPE, FATALITIES, INJURIES, PROPDMG, PROPDMGEXP, CROPDMG, CROPDMGEXP) -> dataPreprocess

#Remove Summary from event type
dataPreprocessed <- dataPreprocessed[!grepl(pattern = "Summary", x=dataPreprocessed$EVTYPE),]

#Create Property damage total
#Type of exponents -> Billion, Million, K thousand
summary(dataPreprocessed)
dataPreprocessed %>%
        mutate(CombinedHealthDamage = FATALITIES + INJURIES) -> dataPreprocessed 

dataPreprocessed %>%
        mutate(multiPROPDM = ifelse(PROPDMGEXP == 'B', 10^9, 
                                    ifelse(PROPDMGEXP == 'M', 10^6, 
                                           ifelse(PROPDMGEXP == 'K', 10^3, 
                                                  ifelse(PROPDMGEXP == 'H', 100, 1))))) %>%
        mutate(totalPROPDMG = as.numeric(multiPROPDM) * as.numeric(PROPDMG)) -> dataPreprocessed


dataAgregateFatalities <- with(dataPreprocess, aggregate(FATALITIES, list(EVTYPE), sum))
dataAgregateFatalities <- rename(dataAgregateFatalities, EVTYPE = Group.1, FATALITIES = x)
dAFatalitiesTop20 <-arrange(dataAgregateFatalities,desc(FATALITIES))[1:20,]

dataAgregateINJURIES <- with(dataPreprocess, aggregate(INJURIES, list(EVTYPE), sum))
dataAgregateINJURIES <- rename(dataAgregateINJURIES, EVTYPE = Group.1, INJURIES = x)
dAINJURIESTop20 <- arrange(dataAgregateINJURIES, desc(INJURIES))[1:20,]

dataAgregateCombined <- with(dataPreprocessed, aggregate(CombinedHealthDamage, list(EVTYPE), sum))
dataAgregateCombined <- rename(dataAgregateCombined, EVTYPE = Group.1, CombinedHealthDamage = x)
dACOMBINEDTop20 <- arrange(dataAgregateCombined, desc(CombinedHealthDamage))[1:20,]

#Change the factor order
dAFatalitiesTop20$EVTYPE <- factor(dAFatalitiesTop20$EVTYPE, levels = dAFatalitiesTop20$EVTYPE[order(dAFatalitiesTop20$FATALITIES)])
dAINJURIESTop20$EVTYPE <- factor(dAINJURIESTop20$EVTYPE, levels = dAINJURIESTop20$EVTYPE[order(dAINJURIESTop20$INJURIES)])
dACOMBINEDTop20$EVTYPE <- factor(dACOMBINEDTop20$EVTYPE, levels = dACOMBINEDTop20$EVTYPE[order(dACOMBINEDTop20$CombinedHealthDamage)])

library(ggplot2)

gf <- ggplot(data=dAFatalitiesTop20, aes(x=EVTYPE, y=FATALITIES , fill=EVTYPE)) +
        geom_bar(stat="identity", show_guide = FALSE) + 
        coord_flip() + geom_text(aes(label=FATALITIES), vjust=0)

gi <- ggplot(data=dAINJURIESTop20, aes(x=EVTYPE, y=INJURIES , fill=EVTYPE)) +
        geom_bar(stat="identity", show_guide = FALSE) + 
        coord_flip() + geom_text(aes(label=INJURIES), vjust=0)

gc <- ggplot(data=dACOMBINEDTop20, aes(x=EVTYPE, y=CombinedHealthDamage , fill=EVTYPE))
gc <- gc + geom_bar(stat="identity", show_guide = FALSE)
gc <- gc + coord_flip() + geom_text(aes(label=CombinedHealthDamage), vjust=0)

require(gridExtra)
grid.arrange(gf, gi, gc, nrow=3)


dataPreprocess %>% 
        mutate(multiPROPDM = ifelse(PROPDMGEXP == 'B', 10^9, 
                                    ifelse(PROPDMGEXP == 'M', 10^6, 
                                           ifelse(PROPDMGEXP == 'K', 10^3, 
                                                  ifelse(PROPDMGEXP == 'H', 100, 1))))) %>%
        mutate(totalPROPDMG = as.numeric(multiPROPDM) * as.numeric(PROPDMG)) -> dataTreated




#FATALITIES INJURIES
#PROPDMG PROPDMGEXP CROPDMG CROPDMGEXP