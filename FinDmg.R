# Analyze Financial Damage

fin <- aggregate(df$TOTDMGDLRS, by=list(Category=df$EVT), FUN=sum)

fin <- fin[order(-fin$x),]

fin15<- fin[1:15,]
plot(hist(fin$x))
