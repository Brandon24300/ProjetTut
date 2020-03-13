source("projettut\\util.R")


# Installation et chargement automatique des packages si nÃ©cessaire
packages <- c("xml2", "RCurl", "RSQLite")
installPackages(packages)
library(xml2)
library(RCurl)
library(RSQLite)
source("projettut\\database.R")
source("projettut\\parser.R")
createTables()


url <- "https://www.interieur.gouv.fr/avotreservice/elections/telechargements/DP2015/resultatsT1/001/00100000.xml"
aResultat <- parseXmlFile(url)
source("projettut\\database.R")


test <- c("aaaa", "ddd")
a <- sprintf("'%s'", test)
a

start.time <- Sys.time()
d = creerTest(aResultat)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
# 450 ms plein de requete en une transaction
# 260 ms
# Sans transaction = 1 minute 27
# Modification mode ecriture, new time = identique
# Transaction = 30 Seconde sur les candidats
# 22 Seconde
# 21.8


