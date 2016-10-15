# Analyze Financial Damage

fin <- aggregate(df$TOTDMGDLRS, by=list(Category=df$EVT), FUN=sum)

fin <- fin[order(-fin$x),]

p <- ggplot(data=fin, aes(x=fin$x, y=fin$Category) + geom_point(size=3))
p
