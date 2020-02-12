db <- NULL

createTables <- function(){
  db <- getDbConnexion()
  
  dbExecute(conn = db,
                    "CREATE TABLE IF NOT EXISTS Region(
      idRegion INT PRIMARY KEY NOT NULL,
      nomRegion CHAR(50) NOT NULL);
      CREATE TABLE Departement(
      idDpt INT PRIMARY KEY NOT NULL,
      nomDpt CHAR(50) NOT NULL,
      regionId INT,
      foreign key(regionId) references Region(idRegion)
      );"
   )
  
  dbExecute(conn = db,
              "
      CREATE TABLE IF NOT EXISTS BureauVote(
        idBureauVote INT PRIMARY KEY NOT NULL,
        dptId INT NOT NULL,
        foreign key(dptId) references Departement(idDpt)
    );"
  )
  
  dbExecute(conn = db,
        "CREATE TABLE IF NOT EXISTS TypeElection(
          idTypeElection INT PRIMARY KEY NOT NULL,
          nomTypeElection CHAR(50) NOT NULL
        );"
  )
  
  dbExecute(conn = db,
              "
        CREATE TABLE IF NOT EXISTS Election(
          idElection INT PRIMARY KEY NOT NULL,
          annee INT NOT NULL,
          typeElectionId INT NOT NULL,
          foreign key(typeElectionId) references TypeElection(idTypeElection)
        );
        "
  )
  
  dbExecute(conn = db,
              "
         CREATE TABLE IF NOT EXISTS PartiPolitique(
    idPartiPolitique INT PRIMARY KEY NOT NULL,
    libelleParti CHAR(50) NOT NULL);
        "
  )
  
  dbExecute(conn = db,
              "
          CREATE TABLE IF NOT EXISTS Candidat(
            idCandidat int primary key not null,
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
            idResultat int primary key not null,
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

createCandidats <- function(list){
  annee = list$annee
  typeElection = list$typeElection
  codeDepartement = list$codeDepartement
  nomDepartement = list$nomDepartement
  candidats = list$candidats
  
  print(annee)
  print(typeElection)
  print(codeDepartement)
  
  for(index in length(candidats)){
    candidat = candidats[[index]]
    nom = candidat$NomPsn
    prenom = candidat$PrenomPsn
    civilite = candidat$CivilitePsn
    partie = candidat$LibNua
    
  }
  
  
}



