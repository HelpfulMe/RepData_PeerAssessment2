# Analyze Fatalities

# total the fatalities by event type
fatal <- aggregate(df$FATALITIES, by=list(Category=df$EVT), FUN=sum)

# sort from most deadly to least
fatal <- fatal[order(-fatal$x),]

# take the top 15
fatal15<- fatal[1:15,]

# and plot them
# Fitting Labels 
par(las=2) # make label text perpendicular to axis
par(mar=c(5,10,4,2)) # increase y-axis margin.

barplot(fatal15$x, main="Fatalities by Event Type", 
        xlab= "Fatalities", 
        horiz=TRUE,
        names.arg=fatal15$Category, cex.names=0.8)