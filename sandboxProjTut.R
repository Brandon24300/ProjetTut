source("projettut\\util.R")
packages <- c("leaflet", "maps", "raster", "stringr")
installPackages(packages)
library(leaflet)
library(maps)
library(raster)
library(stringr)


m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map

# Conversion en df pour utilisation facilit�e
villes <- data.frame(Ville = c("Paris", "Lille", "Nantes", "Marseille","IUT P�rigueux","test"),
                     Latitude = c(48.85661400000001, 50.62924999999999, 47.218371, 43.296482, 45.196660, -0.812),
                     Longitude = c(2.3522219000000177, 3.057256000000052, -1.553621000000021, 5.369779999999992, 0.718624, 47.479),
                     Population = c(2249975, 227560, 284970, 850726, 5000, 965494))

# 
m <- leaflet(villes) %>% addTiles() %>%
  addCircles(lng = ~Longitude, lat = ~Latitude, weight = 1,
             radius = ~sqrt(Population) * 50, popup = ~paste(Ville, ":", Population),
             color = "#a500a5", fillOpacity = 0.5)
m


mapFr = map("france", fill = TRUE, plot = FALSE)
leaflet(data = mapFr) %>% addTiles() %>%
  addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)


# Import tableau d'�quivalence r�gion/dpt
region_corres <- read.csv("https://www.data.gouv.fr/s/resources/correspondance-zeat-region-departements/20150126-140646/ZEAT_regions_departements.csv", header = FALSE, encoding="UTF-8")
names(region_corres) <- c("index","grande_region", "num","region","D�partement")
region_corres


###### D�coupage en d�partement

#### getdata(1, 2, 3) : Fonction native incroyable qui regroupe tous les territoires mondiales (et plus) avec coord' g�o'
?getData()

##     1
# Choix du type de donn�es voulues
# 'alt' stands for altitude (elevation); the data were aggregated from SRTM 90 m resolution data
#       between -60 and 60 latitude.
# 'GADM' is a database of global administrative boundaries.
# 'worldclim' is a database of global interpolated climate data.
# 'SRTM' refers to the hole-filled CGIAR-SRTM (90 m resolution).
# 'countries' has polygons for all countries at a higher resolution 
#             than the 'wrld_simpl' data in the maptools package

##    2
# Choix du pays

##    3
# Choix du niveau de zoom de la carte
# 1 pour la vue la plus g�n�rale du pays
# 2 pour la vue au niveau d�partementale
#


FranceFormesReg <- getData(name="GADM", country="FRA", level=1, )
FranceFormesDpt <- getData(name="GADM", country="FRA", level=2)

tail(FranceFormesDpt)
length(FranceFormesReg[1,])

FranceFormesReg$NAME_1

FranceFormes$GID_1
FranceFormes$NAME_2

str(FranceFormesReg@polygons[12]) ; FranceFormesReg$NAME_1[12] ; FranceFormesReg@proj4string




## gouv.data : https://www.data.gouv.fr/fr/datasets/elections-presidentielles-1965-2012-1/

# Test pour niveau d�partementale Pr�sidentielle 2002

# Premier DataFrame des r�sultats des pr�sidentielles de 2002
resPresidRegion2002 <- data.frame(read.csv("presidDpt2002.csv", header=TRUE, sep=";"))

# Giga objet avec d�partement, r�gion et position g�ographique venant d'une base de l'organisme GADM (� v�rifier si possible d'utiliser pour projet)
FranceFormesDpt <- getData(name="GADM", country="FRA", level=2) 

class(FranceFormesDpt)
names(FranceFormesDpt)

# Pour acc�der aux donn�es spatial en listes de coordonn�es (points) qui forment des polygones repr�sentant les d�partements
head(FranceFormesDpt@polygons)


#�tablissement de l'index qui permet de "lier" les deux DataFrame ()
#Uniformisation des deux listes gr�ce � deux fonctions
idx <- match(str_to_upper(Unaccent(FranceFormesDpt$NAME_2)), resPresidRegion2002[,2])


#Tranfert des donn�es pour toutes les r�gions du nombre d'inscrits

listTypeData <- as.character(names(resPresidRegion2002[,-1:-2]))
class(as.character(resPresidRegion2002[idx, listTypeData[1]]))

FranceFormesDpt@data[1,]
FranceFormesDpt@data$i

i <- "Exprim�s"
names(resPresidRegion2002)
concordanceVotants <- resPresidRegion2002[idx, i]
FranceFormesDpt@data$Votants <- concordanceVotants
class(concordanceVotants)

formes$names["Votants"]

data <- resPresidRegion2002[idx, i]
data <- c(data, resPresidRegion2002[idx, i])
min(na.omit(resPresidRegion2002[idx, i]))
max(na.omit(resPresidRegion2002[idx, i]))
median(na.omit(resPresidRegion2002[idx, i]))
summary(na.omit(resPresidRegion2002[idx, i]))
#Tracage de la carte : Inscrits
#Charte des couleurs puis tracage de la carte
couleurs <- colorRampPalette(c('white','blue'))
spplot(FranceFormesDpt, "Votants", col.regions=couleurs(16),  main=list(label="",cex=.8))
?spplot
?colorRamp
FranceFormesDpt$NAME_2[max(na.omit(FranceFormesDpt$Votants))]
