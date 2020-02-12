source("projettut\\util.R")
source("projettut\\database.R")
source("projettut\\parser.R")
# Installation et chargement automatique des packages si nÃ©cessaire
packages <- c("xml2", "RCurl", "RSQLite")
installPackages(packages)
library(xml2)
library(RCurl)
library(RSQLite)
createTables()

# Permet de voir dans la console R toutes les tables crées
dbListTables(getDbConnexion())

#aListUrlElections <- genererUrlElectionsWithRegex()
sUrl = "https://www.interieur.gouv.fr/avotreservice/elections/telechargements/LG2017/resultatsT1/001/00101024.xml"
listCandidats = parseXmlFile(sUrl, "autre")
# Méthode a renommer 
# Permet d'insérer le résultat de parseXml File en base
# Méthode non terminé 
# Il manque l'insertion des votes blancs, null
# et insertion resultat
creerTest(listCandidats)




