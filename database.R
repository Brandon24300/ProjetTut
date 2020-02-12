db <- NULL

createTables <- function(){
  db <- getDbConnexion()
  
  dbExecute(conn = db,
                    "
      CREATE TABLE Departement(
        idDpt INTEGER PRIMARY KEY AUTOINCREMENT,
        nomDpt CHAR(50) NOT NULL
      );"
   )
  
  dbExecute(conn = db,
              "
      CREATE TABLE IF NOT EXISTS BureauVote(
        idBureauVote INTEGER PRIMARY KEY AUTOINCREMENT,
        dptId INT NOT NULL,
        foreign key(dptId) references Departement(idDpt)
    );"
  )
  
  dbExecute(conn = db,
        "CREATE TABLE IF NOT EXISTS TypeElection(
          idTypeElection INTEGER PRIMARY KEY AUTOINCREMENT,
          nomTypeElection CHAR(50) NOT NULL
        );"
  )
  
  dbExecute(conn = db,
              "
        CREATE TABLE IF NOT EXISTS Election(
          idElection INTEGER PRIMARY KEY AUTOINCREMENT,
          annee INT NOT NULL,
          typeElectionId INT NOT NULL,
          foreign key(typeElectionId) references TypeElection(idTypeElection)
        );
        "
  )
  
  dbExecute(conn = db,
              "
         CREATE TABLE IF NOT EXISTS PartiPolitique(
    idPartiPolitique INTEGER PRIMARY KEY AUTOINCREMENT,
    libelleParti CHAR(50) NOT NULL);
        "
  )
  
  dbExecute(conn = db,
              "
          CREATE TABLE IF NOT EXISTS Candidat(
            idCandidat INTEGER primary key AUTOINCREMENT,
            nomCandidat char(50) not null,
            prenomCandidat char(50) not null,
            sexe char(10),
            partiPolitiqueId int not null,
            foreign key(partiPolitiqueId) references PartiPolitique(idPartiPolitique)
          );
        "
  )
  
   dbExecute(conn = db,
              "
         CREATE TABLE IF NOT EXISTS Resultat(
            idResultat INTEGER primary key AUTOINCREMENT,
            votes int,
            votesBlanc int,
            votesNul int,
            electionId int not null,
            candidatId int not null,
            bureauVoteId int not null,
            foreign key(electionId) references Election(idElection),
            foreign key(candidatId) references Candidat(idCandidat),
            foreign key(bureauVoteId) references BureauVote(idBureauVote)
          );
        "
  )
   
  dbDisconnect(conn = db)
}

getDbConnexion <- function(){
  if(is.null(db)){
    sqlConn <- SQLite()
    db <- dbConnect(sqlConn, dbname = "stockage.sqlite")
  }

  return(db)
}

creerTest <- function(list){
  annee = list$annee
  typeElection = list$typeElection
  codeDepartement = list$codeDepartement
  nomDepartement = list$nomDepartement
  candidats = list$candidats
  connexion <- getDbConnexion()
  
  idDepartement = getIdDepartementByName(nomDepartement)
  # Si le departement n'existe pas alors on le crée
  if (is.null(idDepartement)) {
    idDepartement = creerDepartement(nomDepartement)
  }
  
  
  idTypeElection = getIdTypeElectionByName(typeElection)
  # Si le type Elections n'existe pas alors on le crée
  if (is.null(idTypeElection)) {
    idTypeElection = creerTypeElection(nomDepartement)
  }
  
  #Requete insertion candidats
  requeteCreationCandidat <- "insert into candidat(nom, prenom, sexe, partie_politique_id) VALUES ('%s', '%s', '%s', %s)"
  
  # Pour éviter de bombarder la base de requête on recupere tous les parties politique déjà existant
  # et on va regarder si le partie politique existe dans notre dataFrame pour récupérer l'id
  # Afin qu'on puisse respecter notre contrainte de clé étrangére sur la table resultat et candidat
  dfPartiePolitiqueExistant <- getAllPartiePolitique()
  
  for(index in 1:length(candidats)){
    candidat = candidats[[index]]
    nom = candidat$NomPsn
    prenom = candidat$PrenomPsn
    civilite = candidat$CivilitePsn
    nomPartie = candidat$LibNua
    idPartiePolitique = NULL
    print(nom)
    
    if (is_empty(dfPartiePolitiqueExistant) == FALSE) {
      # Recuperation de toutes les lignes qui ont le même nom de partie
      # Normalement s'il n'y a pas de doublon il ne devrait y avoir qu'une seul ligne
      dfPartiePolitique <- dfPartiePolitiqueExistant[dfPartiePolitiqueExistant$libelleParti == nomPartie, ]
      # Si il y a des resultat alors on recupere le premier partie politique matchant
      if (nrow(dfPartiePolitique) > 0) {
        idPartiePolitique <- dfPartiePolitique$idPartiPolitique[1]
      }
      
    }
    
    if (is.null(idPartiePolitique)) {
      print(nomPartie)
      idPartiePolitique = creerPartiePolitique(nomPartie)
      # Ajout du nouveau partie politique a notre data frame
      dfPartiePolitiqueExistant[nrow(dfPartiePolitiqueExistant) + 1,] = list(idPartiePolitique,nomPartie)
    }
    creerCandidat(prenom, nom, civilite, idPartiePolitique)
    
  }
  
}
# ============================ Methode Table Candidat ======================================
# Renvoie null si l'id n'existe pas 
creerCandidat <- function(firstName, name, sexe, idPartiePolitique){
  conn <- getDbConnexion()

  query <- sprintf(
    "insert into Candidat (nomCandidat, prenomCandidat, sexe, partiPolitiqueId) VALUES ('%s', '%s', '%s', %s)",
    name, firstName, sexe, idPartiePolitique)
  
  dbExecute(conn, query)
  candidat <- getCandidat(firstName, name, idPartiePolitique)
  return()
}

getCandidat <- function(prenomCandidat, nomCandidat, idPartiePolitique){
  conn <- getDbConnexion()
  query <- sprintf(
    "SELECT * FROM Candidat where nomCandidat = '%s' and prenomCandidat = '%s' and partiPolitiqueId = %s",
    nomCandidat, prenomCandidat, idPartiePolitique
  )
  rs <- dbSendQuery(conn, query)
  df <- dbFetch(rs) # Retourne un data Frame
  dbClearResult(rs)
  
  return(df)
}

getAllCandidats <- function(){
  conn <- getDbConnexion()
  query <- "SELECT * FROM Candidat"
  rs <- dbSendQuery(conn, query)
  df <- dbFetch(rs) # Retourne un data Frame
  dbClearResult(rs)
  
  return(df)
}


# ============================ FIN Methode Table Candidat ======================================

# ============================ Methode Table Partie Politique ======================================
getIdPartiePolitiqueByName <- function(pname){
  conn <- getDbConnexion()
  print(pname)
  query <- dbSendQuery(conn, "SELECT idPartiPolitique FROM PartiPolitique WHERE libelleParti = '?'")
  rs <- dbBind(query, list(pname))
  df <- dbFetch(rs)
  idPartie = NULL
  if (dbGetRowCount(rs) > 0) {
    idPartie <- df[1,] # Premiere Ligne
  }
  
  dbClearResult(rs)
  
  return(idPartie)
}

getAllPartiePolitique <- function(){
  conn <- getDbConnexion()
  rs <- dbSendQuery(conn, "SELECT idPartiPolitique, libelleParti FROM PartiPolitique")
  df <- dbFetch(rs) # Retourne un data Frame
  dbClearResult(rs)
  
  return(df)
}

# Renvoie null si l'id n'existe pas 
creerPartiePolitique <- function(name){
  conn <- getDbConnexion()
  query <- sprintf("insert into PartiPolitique (libelleParti) VALUES ('%s')", name)
  print(query)
  dbExecute(conn, query)
  idPartieCreer <- getIdPartiePolitiqueByName(name)
  print(idPartieCreer)
  return(idPartieCreer)
}

# ============================ Fin Methode Table Partie Politique ======================================

# ============================ Methode Table Departement ======================================

creerDepartement <- function(name){
  conn <- getDbConnexion()
  dbExecute(conn, sprintf("insert into departement (nomDpt) VALUES ('%s')", name))
  idPartieCreer <- getIdDepartementByName(name)
  return(idPartieCreer)
}
# Renvoie null si l'id n'existe pas 
getIdDepartementByName <- function(name){
  conn <- getDbConnexion()
  
  query <- dbSendQuery(conn, "SELECT idDpt FROM departement WHERE nomDpt = '?'")
  rs <- dbBind(query, list(name))
  df <- dbFetch(rs)
  idPartie = NULL
  if (dbGetRowCount(rs) > 0) {
    idPartie <- df[1,] # Premiere Ligne
  }
  
  dbClearResult(rs)
  
  return(idPartie)
}

# ============================ Fin Methode Table Departement ======================================


# ============================ Methode Table Type Election ======================================

creerTypeElection <- function(name){
  conn <- getDbConnexion()
  dbExecute(conn, sprintf("insert into TypeElection (nomTypeElection) VALUES ('%s')", name))
  idPartieCreer <- getIdTypeElectionByName(name)
  return(idPartieCreer)
}
# Renvoie null si l'id n'existe pas 
getIdTypeElectionByName <- function(name){
  conn <- getDbConnexion()
  query <- dbSendQuery(conn, "SELECT idTypeElection FROM TypeElection WHERE nomTypeElection = '?'")
  rs <- dbBind(query, list(name))
  df <- dbFetch(rs)
  idPartie = NULL
  if (dbGetRowCount(rs) > 0) {
    idPartie <- df[1,] # Premiere Ligne
  }
  
  dbClearResult(rs)
  
  return(idPartie)
}

# ============================ Fin Methode Table Type Election ======================================

# ============================  Methode Table Election ======================================
creerElection <- function(annee, typeElectionId){
  conn <- getDbConnexion()
  dbExecute(conn, sprintf("insert into Election (annee,typeElectionId) VALUES (%s,%s)", annee, typeElectionId))
  idPartieCreer <- getIdPartiePolitiqueByName(name)
  return(idPartieCreer)
}
# ============================ Fin Methode Table Election ======================================
