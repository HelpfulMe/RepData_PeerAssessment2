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

# Stop the clock
elapsed <- proc.time() - ptm
# no colclasses = user - 174.04, system = 10.75, elapsed = 13830.68
# no colclasses = user - 268.75, system = 11.78, elapsed = 14890.06

##------------------------------------------------------------------------------
# Preprocessing data

# add each entry's injury, fatality, and damage vectors-
# can ID records we are interested in
stormData$HARMFUL <- rowSums(stormData[, c("FATALITIES", "INJURIES", "CROPDMG",
                                           "PROPDMG")])



# Official EVTYPES - 48 types in the Storm Data Event Table, pg 6 of
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


# subset data for just events causing propety damage, and events causing
# health consequences
DMG <- subset(stormData, (rowSums(stormData[, c("CROPDMG", "PROPDMG")])) > 0)
HLTH <- subset(stormData, (rowSums(stormData[, c("INJURIES", "FATALITIES")]))>0)



