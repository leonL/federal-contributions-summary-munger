source("lib-constants.R")
source("lib-util.R")
library(dplyr, quietly=TRUE, warn.conflicts=FALSE)

allSourceDataFiles <- list.files(k$summariesSourcePath)

dataSet <- data.frame()

for(file in allSourceDataFiles) {
  print(paste("Munging:", file))

  currentYear <- strsplit(file, ".", fixed=TRUE)[[1]][2]
  filePath <- paste(k$summariesSourcePath, "", file, sep = '/')

  csv <- read.csv(filePath, header=FALSE, as.is=TRUE, encoding="UTF-8")
  colnames(csv) <- k$sourceColNames

  csv$party_riding_name <- aaply(csv$party_riding_name, 1, RemoveYearSuffix)

  # remove commas for n_contibutor.x values and cast to integer
  nColIndices <- grep("n_contributors", colnames(csv))
  csv[, nColIndices] <- lapply(csv[, nColIndices], FormattedNumberStrAsInteger)

  # add columns
  federalContrib <- csv$party_riding_name %in% k$partyFullNames
  currentParty <- csv$party_riding_name[federalContrib][1]

  csv$year <- currentYear
  csv$federal_contribution <- federalContrib
  csv$party_name <- currentParty

  csv <- # add n_contributors.over_200 column
    mutate(csv,
      n_contributors.over_200 = (
        n_contributors - n_contributors.200_or_less - n_contributors.20_or_less
      )
    )

  dataSet <- rbind(dataSet, csv)

}

# print("Merge in normalized riding names and ids...")
# ridingConcordance <-
#   read.csv(
#     paste(k$sourcePath, "patry_to_official_riding_name_concordance.csv", sep="/"),
#     as.is=TRUE, encoding="UTF-8"
#   )
# dataSet <- merge(dataSet, ridingConcordance, all.x=TRUE)