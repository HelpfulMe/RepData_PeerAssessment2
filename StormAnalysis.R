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
    select = c(EVTYPE, FATALITIES, INJURIES, PROPDMG, PROPDMGEXP, CROPDMG,
               CROPDMGEXP, REMARKS, REFNUM))
# 254633 obs

##------------------------------------------------------------------------------
# Calculate Damage
# [""] = multiply DMG by 1
# [0] = multiply DMG by 1 (examining the data entries of '0' may be mistakes
#       with larger exps desired, but there is no way to tell for every entry
#       which exponent was meant to be entered.  Rather than entering '0' for
#       damage i am opting to retain the dollar amount entered in these cases)
# [k/K] = multiply DMG by 1,000
# [m/M] = multiply DMG by 1,000,000
# [b/B] = multiply DMG by 1,000,000,000
# [?, -,+, 2,3, 4, 5, 6, 7, h, H] = multiply DMG by 1 - impossible to tell
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
index <- intersect(grep("flood", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Flood")

# "Hail"
index <- intersect(grep("hail", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Hail")

# "Heavy Rain"
index <- intersect(grep("heavyrai", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Heavy Rain")

# "Wildfire"
index <- intersect(grep("fire", df$EVTYPE2, ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Wildfire")

# "Thunderstorm Wind"
index <- intersect(grep("thunderstormw|tstmw|thunderstormsw|thundertormw|
                        thunderestormw|thunderstromwind", df$EVTYPE2,
                        ignore.case = TRUE),
                   which(is.na(df$EVT)))
df$EVT[index] <- ("Thunderstorm Wind")

# events that need categories
x <- subset(df, is.na(df$EVT))
y <- sort(unique(x$EVTYPE2))  # unique non-matching categories

# one row has a question mark for EVTYPE.  Cannot categorize it, so remove it
# df <- df[!(df$EVTYPE=="?"),]

# # making new dataframe with semi-exact matches of EVTYPE to the official EVT
# df2 <- df[(grep(paste(EVT,collapse="|"), df$EVTYPE, ignore.case = TRUE,
#                 value = FALSE)), ]
#

#
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

