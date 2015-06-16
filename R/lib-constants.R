if(!exists("k")) { k <- list() }

k <- within(k, {
  partyNicknames <- c('Bloc', 'Conservative', 'Green', 'Liberal', 'NDP')

  partyFullNames <- c("Bloc Québécois", "Conservative Party of Canada",
      "Green Party of Canada", "Liberal Party of Canada", "New Democratic Party")

  partyNames <- data.frame(name=partyFullNames, nick_name=partyNicknames)

  allYears <- as.character(c(2004:2015))

  sourcePath <- "../data/source"
  summariesSourcePath <- "../data/source/summaries"

  outputPath <- "../data/output"

  sourceColNames <- c(
    'party_riding_name',
    'total_contributions',
    'total_contributions.over_200',
    'total_contributions.200_or_less',
    'total_contributions.20_or_less',
    'n_contributors',
    'n_contributors.200_or_less',
    'n_contributors.20_or_less'
  )
})