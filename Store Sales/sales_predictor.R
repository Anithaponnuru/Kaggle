#Kaggle Competition - Rossmann Store Sales

#Read input
dir = 'input/'
store = read.csv(paste0(dir,"store.csv"), na.strings = c("NA", ''))
train = read.csv(paste0(dir,"train.csv"))
test = read.csv(paste0(dir,"test.csv"))

#Merge datasets
train = merge(train, store)
test = merge(test,store)

#Data Cleanup
##Fix NAs in Open in test
test$Open[which(is.na(test$Open))] = 0

##Conversions to factors
processData = function(df){
    df$SchoolHoliday = as.factor(df$SchoolHoliday)
    df$Open = as.factor(df$Open)
    df$Promo = as.factor(df$Promo)
    df$CompetitionDistance[is.na(df$CompetitionDistance)] = max(df$CompetitionDistance[!is.na(df$CompetitionDistance)]) * 1.5
    df$Promo2 = as.factor(df$Promo2)
    
    #Convert NA into factors
    df$PromoInterval = addNA(df$PromoInterval)
    df$CompetitionOpenSinceYear = addNA(df$CompetitionOpenSinceYear)
    df$CompetitionOpenSinceMonth = addNA(df$CompetitionOpenSinceMonth)
    df$Promo2SinceWeek = addNA(df$Promo2SinceWeek)
    df$Promo2SinceYear = addNA(df$Promo2SinceYear)
    
    #Parsing and conversion of dates to factors
    df$Date = as.Date(df$Date)
    df$Month = as.integer(format(df$Date, "%m"))
    df$Year = as.integer(format(df$Date, "%y"))
    df$Day = as.integer(format(df$Date, '%d'))
    df$Week = 0
    df$Week[df$Day >= 01 & df $Day <= 07] = 1
    df$Week[df$Day >= 08 & df $Day <= 14] = 2
    df$Week[df$Day >= 15 & df $Day <= 21] = 3
    df$Week[df$Day >= 22 & df $Day <= 28] = 4
    df$Week[df$Day >= 29 & df $Day <= 31] = 5
    df$Day = NULL
    df$Month = as.factor(df$Month)
    df$Year = as.factor(df$Year)
    df$Week = as.factor(df$Week)
    df$Date = NULL
    
    ##Feature engineering
    ##Switch DayOFWeek into weekday/weekend
    df$Weekday = 0
    df$Weekend = 0
    df$Weekday[df$DayOfWeek >= 1 & df$DayOfWeek <= 5] = 1
    df$Weekend[df$DayOfWeek >= 6 & df$DayOfWeek <= 7] = 1
    df$Weekday = as.factor(df$Weekday)
    df$Weekend = as.factor(df$Weekend)
    df$DayOfWeek = NULL
    
    return(df)
}

train = processData(train)
test = processData(test)

#Prediction
##Create a linear model for Sales
lmModel = lm(Sales ~ . - Customers, train)
predModel = predict(lmModel, newdata = test)
predModel[predModel < 0] = 0


#Creates submission
submission = data.frame(test$Id)
names(submission) = 'ID'
submission$Sales = predModel
write.csv(submission, file="sales.csv", row.names=FALSE)
