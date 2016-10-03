##------------------------------------------------------------------------------
## Becca Smith
## Reproducible Research - Johns Hopkins Coursera
## Peer Graded Assignment 2
## Date: October 2, 2016
##------------------------------------------------------------------------------
### Loading and preprocessing the data

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
    # Set column classes
    # not setting date formats - not going to use them for this code
    classes <- c("numeric", "character", "character", "character", "numeric",
                 "character", "character", "character", "numeric", "character",
                 "character", "character", "character", "numeric", "logical",
                 "numeric", "character", "character", "numeric", "numeric",
                 "integer", "numeric", "numeric", "numeric", "numeric",
                 "character", "numeric", "character", "character", "character",
                 "character", "numeric","numeric", "numeric", "numeric",
                 "character", "numeric")
    # read data
    stormData <- read.csv("repdata%2Fdata%2FStormData.csv.bz2", header = TRUE,
                          colClasses = classes, stringsAsFactors = FALSE,
                          na.strings = "NA")
}

# Stop the clock
elapsed <- proc.time() - ptm

