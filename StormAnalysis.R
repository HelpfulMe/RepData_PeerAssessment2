##------------------------------------------------------------------------------
## Becca Smith
## Reproducible Research - Johns Hopkins Coursera
## Peer Graded Assignment 2
## Date: October 2, 2016
##------------------------------------------------------------------------------
### Loading the data

# Start the clock!
ptm <- proc.time()

# For Becca, set wd
setwd("C:/Users/Becca/Dropbox/Personal/Data Science Specialization/Reproducible Research/RepData_PeerAssessment2")

# See if data file is in working directory.  If not, get it
if(!file.exists("repdata%2Fdata%2FStormData.csv.bz2")) {
    fileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
    download.file(fileURL, "repdata%2Fdata%2FStormData.csv.bz2")
}

# See if data read into R.  If not, read it.
if(!exists('stormData')){
    # Unsuccessful at setting colclasses for import, just importing regularly
    # read data
    stormData <- read.csv("repdata%2Fdata%2FStormData.csv.bz2", header = TRUE,
                          stringsAsFactors = FALSE, na.strings = "NA")
}

##------------------------------------------------------------------------------
# Preprocessing data

# Limiting records
# create dataframe with only events that had health or damage consequence
df <- subset(stormData, (rowSums(
    stormData[, c("FATALITIES", "INJURIES", "CROPDMG","PROPDMG")]))>0,
    select = c(BGN_DATE, EVTYPE, FATALITIES, INJURIES, PROPDMG, PROPDMGEXP, 
               CROPDMG, CROPDMGEXP, REMARKS, REFNUM))
# 254633 obs

# According to NOAA records, all event types were only logged starting in 1/1996
# Since we want to compare all event types we only want the data from 1996
# onwards.(see- http://www.ncdc.noaa.gov/stormevents/details.jsp?type=eventtype)

# Start by converting the BGN_DATE column to a date format
df$BGN_DATE <- as.Date(df$BGN_DATE, "%m/%d/%Y")
# Then pull just the year from the date and format as numeric
df$BGN_DATE <- as.numeric(format(df$BGN_DATE,"%Y"))
# Now we can subset the dataframe to rows with a date equal to or greater than
# 1996
df <- subset(df, BGN_DATE >= 1996)
# 201318 obs

##------------------------------------------------------------------------------
# Calculate Damage
# [""] = multiply DMG by 1
# [0] = multiply DMG by 1 (examining the data entries of '0' may be mistakes
#       with larger exps desired, but there is no way to tell for every entry
#       which exponent was meant to be entered.  Rather than entering '0' for
#       damage i am opting to retain the dollar amount entered in these cases)
# [h/H] = multiply DMG by 100
# [k/K] = multiply DMG by 1,000
# [m/M] = multiply DMG by 1,000,000
# [b/B] = multiply DMG by 1,000,000,000
# [?, -,+, 2,3, 4, 5, 6, 7] = multiply DMG by 1 - impossible to tell
#       what exponent desired

# Start DMGDLRS off by copying the DMG amts
df$PROPDMGDLRS <- df$PROPDMG
df$CROPDMGDLRS <- df$CROPDMG

# Calculate the EXPs
# Bs
index <- grep("b", df$PROPDMGEXP, ignore.case = TRUE)
df$PROPDMGDLRS[index] <- (df$PROPDMG[index] * 1000000000)

index <- grep("b", df$CROPDMGEXP, ignore.case = TRUE)
df$CROPDMGDLRS[index] <- (df$CROPDMG[index] * 1000000000)

# Ms
index <- grep("m", df$PROPDMGEXP, ignore.case = TRUE)
df$PROPDMGDLRS[index] <- (df$PROPDMG[index] * 1000000)

index <- grep("m", df$CROPDMGEXP, ignore.case = TRUE)
df$CROPDMGDLRS[index] <- (df$CROPDMG[index] * 1000000)

# Ks
index <- grep("k", df$PROPDMGEXP, ignore.case = TRUE)
df$PROPDMGDLRS[index] <- (df$PROPDMG[index] * 1000)

index <- grep("k", df$CROPDMGEXP, ignore.case = TRUE)
df$CROPDMGDLRS[index] <- (df$CROPDMG[index] * 1000)

# Hs
index <- grep("h", df$PROPDMGEXP, ignore.case = TRUE)
df$PROPDMGDLRS[index] <- (df$PROPDMG[index] * 100)

index <- grep("h", df$CROPDMGEXP, ignore.case = TRUE)
df$CROPDMGDLRS[index] <- (df$CROPDMG[index] * 100)

# Property and Crop Damage totals
df$TOTDMGDLRS <- df$PROPDMGDLRS + df$CROPDMGDLRS

##------------------------------------------------------------------------------
# Categorizing EVTYPES

# Official EVTYPES - types in the Storm Data Event Table, pg 6 of
# https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf
EVT <- c('Astronomical Low Tide','Avalanche','Blizzard','Coastal Flood',
              'Cold/Wind Chill','Debris Flow','Dense Fog','Dense Smoke',
              'Drought','Dust Devil','Dust Storm','Excessive Heat',
              'Extreme Cold/Wind Chill','Flash Flood','Flood','Frost/Freeze',
              'Funnel Cloud','Freezing Fog','Hail','Heat','Heavy Rain',
              'Heavy Snow','High Surf','High Wind','Hurricane (Typhoon)',
              'Ice Storm','Lake-Effect Snow','Lakeshore Flood','Lightning',
              'Marine Hail','Marine High Wind','Marine Strong Wind',
              'Marine Thunderstorm Wind','Rip Current','Seiche','Sleet',
              'Storm Surge/Tide','Strong Wind','Thunderstorm Wind','Tornado',
              'Tropical Depression','Tropical Storm','Tsunami','Volcanic Ash',
              'Waterspout','Wildfire','Winter Storm','Winter Weather')

# create second vector for event types without punctuation or captialization
EVT2 <- tolower(EVT)
# remove spaces and punctuation
EVT2 <- gsub("[^[:alnum:]]", "", EVT2)
# combine the EVT vectors
EVT <- cbind.data.frame(EVT, EVT2, stringsAsFactors = FALSE)

# set up new column in df for event types without punctuation or capitalization
df$EVTYPE2 <- tolower(df$EVTYPE)
df$EVTYPE2 <- gsub("[^[:alnum:]]", "", df$EVTYPE2)

# merge EVT and df
df <- merge(x=df, y=EVT, by.x = "EVTYPE2", by.y = "EVT2", all.x = TRUE)

#-------------------------------------------------------------------------------
# Cleaning event types - find events, assign them cleaned up event types

# "Storm Surge/Tide",
# Find events with the search term in their EVTYPE2 vector that also have NA
# for EVT (cleaned up event type)
index <- intersect(grep("stormsurge", df$EVTYPE2, ignore.case = TRUE),
    which(is.na(df$EVT)))
# and assign them the cleaned up event type
df$EVT[index] <- "Storm Surge/Tide"

# "Hurricane (Typhoon)"
index <- intersect(grep("hurri|typhoon", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Hurricane (Typhoon)")

# "Flash Flood"
index <- intersect(grep("flashflood", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Flash Flood")

# "Coastal Flood"
index <- intersect(grep("coastalflood", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Coastal Flood")

# "Flood"
index <- intersect(grep("flood|excessivewetness|andwet|urbansmlstreamfld",
                        df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Flood")

# "Hail"
index <- intersect(grep("hail", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Hail")

# "Wildfire"
index <- intersect(grep("fire", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Wildfire")

# "Thunderstorm Wind"
index <- intersect(grep("thunderstormw|tstmw|thunderstormsw|thundertormw|
                        thunderestormw|thunder|tunderstorm|thuderstorm|
                        THUNDEERSTORM|THUNERSTORM|microburst", 
                        df$EVTYPE2,
                        ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Thunderstorm Wind")

# "High Wind"
index <- intersect(grep("highwind", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("High Wind")

# "Extreme Cold/Wind Chill"
index <- intersect(grep("extremecold", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Extreme Cold/Wind Chill")

# "Strong Wind"
index <- intersect(grep("strongwind", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Strong Wind")

# "Frost/Freeze"
index <- intersect(grep("freeze|frost", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Frost/Freeze")

# "Debris Flow"
index <- intersect(grep("landsl|mudslide", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Debris Flow")

# "High Surf"
index <- intersect(grep("hightide", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("High Surf")

# "Tropical Storm"
index <- intersect(grep("tropicalstorm", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Tropical Storm")

# "Tornado"
index <- intersect(grep("tornado|TORNDAO", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Tornado")

# "Cold/Wind Chill"
index <- intersect(grep("windchill|cold", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Cold/Wind Chill")

# "Heavy Snow"
index <- intersect(grep("snow", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Heavy Snow")

# "Heat"
index <- intersect(grep("heat", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Heat")

# "Dense Fog"
index <- intersect(grep("fog", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Dense Fog")

# "Winter Weather"
index <- intersect(grep("winterwe|freezingrain|freezingdrizzle", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Winter Weather")

# "Winter Storm"
index <- intersect(grep("wintersto|wintrymix", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Winter Storm")

# "Ice Storm"
index <- intersect(grep("ice|glaze", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Ice Storm")

# "Heavy Rain"
index <- intersect(grep("heavyrai|rain", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Heavy Rain")

# "Rip Current"
index <- intersect(grep("rip", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Rip Current")

# "Heat"
index <- intersect(grep("warm", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Heat")

# "High Surf"
index <- intersect(grep("highsurf", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("High Surf")

# "Lightning"
index <- intersect(grep("lighting|ligntning|lightning", df$EVTYPE2,
                        ignore.case = TRUE), which(is.na(df$EVT)))
df$EVT[index] <- ("Lightning")

# events that need categories
x <- subset(df, is.na(df$EVT))

# 431 observations still do not have standardized event types
# these include 114 fatalities, 257 injuries, 30222040 dollars dmg
# standardized are 15145 fatalities, 140528 injuries, 476422842480 dollars dmg
# those not categorized are 0.75% of fatalities, 0.18% of all injuries, and 0.06% of all dmg
# As we are only looking for the top causes of harm to human health and property, I will
# continue without these

# fill in nonstandard event types for those who have not been standardized
index <- which(is.na(df$EVT))
df$EVT[index] <- df$EVTYPE[index]


#
# # subset data for just events causing propety damage, and events causing
# # health consequences
# DMG <- subset(df, (rowSums(df[, c("CROPDMG", "PROPDMG")])) > 0)
# HLTH <- subset(df, (rowSums(df[, c("INJURIES", "FATALITIES")]))>0)
#
#
# Stop the clock
elapsed <- proc.time() - ptm
# no colclasses, loading data only: user = 174.04, system = 10.75, elapsed = 13830.68
# full code, loading data and classifying: user = 314.40, system = 4.19, elapsed = 319.89
# full code, without loading data: user = 20.84, system = 0.47, elapsed = 21.34