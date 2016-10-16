# Analyze Injuries

# total the injuries by event type
injure <- aggregate(df$INJURIES, by=list(Category=df$EVT), FUN=sum)

# sort from most injuries to fewest
injure <- injure[order(-injure$x),]

# take the top 15
injure15<- injure[1:15,]

# and plot them
# Fitting Labels 
par(las=2) # make label text perpendicular to axis
par(mar=c(6,9,4,2)) # increase y-axis margin.

barplot(injure15$x, main="Injuries by Event Type", 
        xlab= "Injuries", 
        horiz=TRUE,
        names.arg=injure15$Category, cex.names=0.8)