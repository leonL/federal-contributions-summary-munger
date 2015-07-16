source("lib-constants.R")
source("lib-util.R")
library(plyr, quietly=TRUE, warn.conflicts=FALSE)
library(dplyr, quietly=TRUE, warn.conflicts=FALSE)

allSourceDataFiles <- list.files(k$summariesSourcePath)

dataSet <- data.frame()

for(file in allSourceDataFiles) {
  print(paste("Munging:", file))

  currentYear <- strsplit(file, ".", fixed=TRUE)[[1]][2]
  filePath <- paste(k$summariesSourcePath, "", file, sep = '/')

  csv <- read.csv(filePath, header=FALSE, as.is=TRUE, encoding="UTF-8")
  colnames(csv) <- k$sourceColNames

  qReturns <- csv[IsQuarterlyReturn(csv$party_riding_name), ]
  if(nrow(qReturns) > 0) {
    qReturnsNumbers <- select(qReturns, -party_riding_name)
    qReturnsNumbers[] <- lapply(qReturnsNumbers, StrToNum)
    quarterlyTotals <- colSums(qReturnsNumbers)
    quarterlyTotals$party_riding_name <- RemoveYearSuffix(qReturns$party_riding_name[1])
    csv <- csv[!IsQuarterlyReturn(csv$party_riding_name), ]
    csv <- rbind(csv, quarterlyTotals)
  }

  # csv$party_riding_name <- aaply(csv$party_riding_name, 1, RemoveYearSuffix)

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

dataSet <- filter(dataSet, total_contributions > 0) # remove empty summaries
IndicesOfEdaSummaries2014 <- # remove 2014 eda summaries
  which(dataSet$year == 2014 & dataSet$federal_contribution == FALSE)
dataSet <- dataSet[-IndicesOfEdaSummaries2014,]

print("Merge in normalized riding names and ids...")
ridingConcordance <-
  read.csv(
    paste(k$sourcePath, "patry_to_official_riding_name_concordance.csv", sep="/"),
    as.is=TRUE, encoding="UTF-8"
  )
dataSet <- merge(dataSet, ridingConcordance, all.x=TRUE)

dataSet <- filter(dataSet, !is.na(riding_id) | federal_contribution) # remove summaries for edas not currently accounted for

dataSet <-
  select(dataSet,
    party_name,
    federal_contribution,
    riding.name=riding_name,
    riding.id=riding_id, year,
    total_contributions,
    total_contributions.over_200,
    total_contributions.200_or_less,
    total_contributions.20_or_less,
    n_contributors,
    n_contributors.over_200,
    n_contributors.200_or_less,
    n_contributors.200_or_less,
    n_contributors.20_or_less
  ) %>% arrange(party_name, desc(federal_contribution), year, riding.id)

print("Wrtie munged data to CSV...")
write.csv(
  dataSet,
  file= paste(k$outputPath, "summaries.csv", sep = '/'),
  row.names=FALSE
)