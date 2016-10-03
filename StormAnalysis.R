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
    # Classes decided by:
    # reading in entire dataframe (reading in partial produced
    #       classes that didn't work),
    # classes <- sapply(stormData, class) # to get classes of dataframe
    # unname(classes) # to remove the names from the classes vector
    # paste("'", classes, "'", sep="", collapse = ", ") # to print comma
    # # separated list to the console that could paste into classes assignment
    # # below
    classes <- c('numeric', 'character', 'character', 'character', 'numeric',
                 'character', 'character', 'character', 'numeric', 'character',
                 'character', 'character', 'character', 'numeric', 'logical',
                 'numeric', 'character', 'character', 'numeric', 'numeric',
                 'integer', 'numeric', 'numeric', 'numeric', 'numeric',
                 'character', 'numeric', 'character', 'character', 'character',
                 'character', 'numeric', 'numeric', 'numeric', 'numeric',
                 'character', 'numeric')

    # read data
    stormData <- read.csv("repdata%2Fdata%2FStormData.csv.bz2", header = TRUE,
                          stringsAsFactors = FALSE, na.strings = "NA")
}

# Stop the clock
elapsed <- proc.time() - ptm
# no colclasses   = user - 174.04, system = 10.75, elapsed = 13830.68
# with colclasses = user - 268.75, system = 11.78, elapsed = 14890.06
# it takes longer to read in the file with colclasses?!


