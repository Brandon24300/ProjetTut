
getRemoteFilesUrl<- function (url)
{
  # Lecture url distantes
  htmlContent = readLines(url)
  # Explication condition regex : https://rstudio.com/wp-content/uploads/2016/09/RegExCheatsheet.pdf
  # Cette Regex a pour but de recuperer le contenu dans la balise a
  # Nous recherchons toutes chaines commencant par <a 
  # Une fois trouver nous indiquons que nous selectionnons tout les caracteres jusqu'a >
  # Apr?s nous indiquons que nous recuperons n'importe quel caractere entre > et <
  # Et que la fin du pattern se termine par le </a>
  sRegexATag = "<a[^>]*>(.+)</a>"
  # La regex nous retourne un tableau en deux dimensions :
  # [][1] = tout la balise a 
  # [][2] = tout le contenu entre <a> ... </a>
  allATag = stringr::str_match_all(htmlContent,sRegexATag)
  # Suppression premier element si c'est le dossier qui ramene au dossier parent
  sParentDirectory = "Parent directory"
  if(grepl(allATag[1][2],sParentDirectory))
  {
    allATag[-1]
  }
  
  aListOfXmlFile = c()
  
  if(is_empty(allATag) == FALSE)
  {
    for (aTag in allATag) 
    {
      # On prend le contenu entre la les crochets du <a> </a>
      xmlFileName = aTag[2]
      
      if(is_empty(xmlFileName) == FALSE)
      {
        iSizeOfATagContent = nchar(xmlFileName)
        cLastChar = substr(xmlFileName,iSizeOfATagContent,iSizeOfATagContent)
        # Si c'est une url de resultat et que le fichier contient le mot com 
        # On le recupere car il nous int?resse
        if (grepl("resultat",url,fixed = TRUE) ) 
        {
          if (grepl("com",xmlFileName,fixed = TRUE)) 
          {
            
          }
          
        }
        # Les cas ou ce n'est pas un fichier de resultat
        else
        {
          # Si c'est un dossier alors on va explorer le repertoire distant
          if (cLastChar == "/") 
          {
            urlWithFolder = paste(url,xmlFileName, sep = "") # Concatenation url et le nom du dossier
            aTempListFiles = getRemoteFilesUrl(urlWithFolder) # Recursif iteration sur le dossier
            # Si dans la recherche du sous dossier il y a des fichiers alors on les concatene a notre list de fichier
            if(is_empty(aTempListFiles) == FALSE)
            {
              aListOfXmlFile <- c(aListOfXmlFile,aTempListFiles)
            }
          }
          # Si c'est un fichier xml alor on l'ajoute a notre liste
          else if(grepl(".xml",xmlFileName,fixed = T))
          {
            sUrlXmlFile <- paste(url,xmlFileName,sep="")
            aListOfXmlFile <- c(aListOfXmlFile,sUrlXmlFile)
          }
        }
      }
    }
  }
  # Retourne la list des resultats
  aResultsList = list("files" = aListOfXmlFile)
  
  return(aResultsList)
}

parseXmlFile <- function(url, model)
{
  xmlFile <- read_xml(url);
  aResultat <- "NULL"
  
  
  
  #Procedure verification existance d'un noeud enfant dans un noeud
  # et creation si n'existe pas
  #r <- xml_add_child(x, "root","lol")
  #xml_add_child(r, xml_comment("Hello!"))
  
  # result = xml_child(fist,"root")
  #if (is_empty(result)) {
  # xml_add_child(fist,"lol","jetedeste")
  #}
  
  
  if(model == "candidat")
  {
    allCandidats <- xml_find_all(xmlFile,".//Candidat") # Extraction de tous les candidats
    sAnnee <- xml_text(xml_find_first(xmlFile,".//Annee")) # Extraction Annee de l'election
    sTypeElection <- xml_text(xml_find_first(xmlFile,".//Type")) # Extraction Type Election
    sCodeDepartement <- xml_text(xml_find_first(xmlFile,".//CodDpt")) # Extraction cpde departement 01 par exemple
    sNomDepartement <- xml_text(xml_find_first(xmlFile,".//LibDpt")) # Extraction nom departement Ain par exemple
    aListCandidats <-  as_list(allCandidats) # Conversion en tableau
    
    aResultat <- c(
      aResultat,
      candidats = list(aListCandidats),
      annee = sAnnee,
      typeElection = sTypeElection,
      codeDepartement = sCodeDepartement,
      nomDepartement = sNomDepartement)
  }
  else
  {
    # iNumTour <- xml_text(xml_find_first(x,".//NumTour")) # Extraction nom departement Ain par exemple
    # Example : https://www.interieur.gouv.fr/avotreservice/elections/telechargements/LG2017/resultatsT1/001/001com.xml
    # Si mega fichier faire un grep sur l'url pour juste recup le mega fichier dans le repertoire
    allCommunes <- xml_find_all(xmlFile,".//Commune")
    scrutin <- as_list(xml_find_first(xmlFile,".//Scrutin"))
    sAnnee <- xml_text(xml_find_first(xmlFile,".//Annee")) # Extraction Annee de l'election
    sTypeElection <- xml_text(xml_find_first(xmlFile,".//Type")) # Extraction Type Election
    sCodeDepartement <- xml_text(xml_find_first(xmlFile,".//CodDpt")) # Extraction cpde departement 01 par exemple
    sNomDepartement <- xml_text(xml_find_first(xmlFile,".//LibDpt")) # Extraction nom departement Ain par exemple
    
    #print(length(allCommunes))
    # aListResultat <- data.frame("candidats", "commune", "votesBlanc", "votesNul")
    aListResultat <- c()
    index = 0
    for (oCommune in allCommunes) 
    {
      #print(index)
      index <- index + 1
      oVotesBlanc <- xml_find_first(oCommune,".//Blancs")
      oVotesNul <- xml_find_first(oCommune,".//Nuls")
      allCandidats <- xml_find_all(oCommune, ".//Candidat")
      
      # Creation du tableau vote blanc puisque la balise n'existe pas 
      if(is_empty(oVotesBlanc))
      {
        aListVotesBlanc = c()
      }
      else
      { # Recuperation des champs dans la balise
        aListVotesBlanc <- as_list(oVotesBlanc) 
      }
      
      # Creation Tableau vote nul
      if(is_empty(oVotesNul))
      {
        aListVotesNul = c()
      }
      else
        #Recuperation champ des champs dans la balise
      {
        aListVotesNul <- as_list(oVotesNul)
      }
      
      # Transformation des objets xml en List
      aListCandidats <- as_list(allCandidats)
      
      # Creation du tableau de reponse
      aResultat <- list(
                        candidats = aListCandidats,
                        commune = "" ,
                        votesBlanc = aListVotesBlanc,
                        votesNul= aListVotesNul,
                        election = scrutin,
                        annee = sAnnee,
                        typeElection = sTypeElection,
                        codeDepartement = sCodeDepartement,
                        nomDepartement = sNomDepartement
                      )
      
      #names(aListResultat)<-c(aListCandidats, "", aListVotesBlanc, aListVotesNul )
      #aListResultat  <- c(aListCandidats, "", aListVotesBlanc, aListVotesNul )
      #aListResultat <- do.call(c,list(aListCandidats, "", aListVotesBlanc, aListVotesNul))
      aListResultat <- append(aListResultat, aResultat)
      #aResultat <- list( commune = "")
      #aListResultat <- append(aListResultat, aResultat)
      #aListResultat <- c(aListResultat, aResultat)
      #print(aListResultat)
      break;
    }
    aResultat <- aListResultat
  }
  
  
  return(aResultat)
}



genererUrlElectionsWithRegex <- function()
{
  # annee correspond aux premieres donn?es disponibles sur le site du gouvernement
  url <- "https://www.interieur.gouv.fr/avotreservice/elections/telechargements/"
  htmlContent = readLines(url)
  # Explication condition regex : https://rstudio.com/wp-content/uploads/2016/09/RegExCheatsheet.pdf
  # Regex qui recupere tout le contenu dans le a tag seulement si 
  # Le pattern dans la balise a commence par DP ou MN ou PR
  # Et que le caractere ou les caracteres qui suivent sont des nombres
  sRegexATag = "<a[^>]+>((DP|MN|PR)([0-9]+))"
  allATag = stringr::str_match_all(htmlContent,sRegexATag)
  aListUrlGenerer <- c()
  
  for (aTag in allATag) 
  {
    sTypeElectionEtAnnee <- aTag[,2]
    iAnnee <- aTag[,4]
    # On skip l'iteration
    if (is_empty(sTypeElectionEtAnnee) || iAnnee < 2012 ) {
      next
    }
    # On prend le contenu entre la les crochets du <a> </a>
    sUrlElection = paste(url, sTypeElectionEtAnnee, sep = "")
    aListUrlGenerer <- c(aListUrlGenerer, sUrlElection)
    
  }
  
  
  return(aListUrlGenerer)
}