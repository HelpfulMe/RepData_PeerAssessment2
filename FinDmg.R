# Analyze Financial Damage

# total the damage by event type
fin <- aggregate(df$TOTDMGDLRS, by=list(Category=df$EVT), FUN=sum)

# sort from most expensive to least
fin <- fin[order(-fin$x),]

# take the top 15
fin15<- fin[1:15,]
# convert currency from dollars to billions
fin15$x <- fin15$x/1000000000

# and plot them
# Fitting Labels 
par(las=2) # make label text perpendicular to axis
par(mar=c(5,8,4,2)) # increase y-axis margin.

barplot(fin15$x, main="Crop and Property Damage by Event Type", 
        xlab= "Damage (Billions USD)", 
        horiz=TRUE,
        names.arg=fin15$Category, cex.names=0.8)