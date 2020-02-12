source("projettut\\util.R")
source("projettut\\database.R")
source("projettut\\parser.R")
# Installation et chargement automatique des packages si nÃ©cessaire
packages <- c("xml2", "RCurl", "RSQLite")
installPackages(packages)
loadPackages(packages)
library(RSQLite)
createTables()

# Permet de voir dans la console R toutes les tables crées
dbListTables(getDbConnexion())

#aListUrlElections <- genererUrlElectionsWithRegex()






