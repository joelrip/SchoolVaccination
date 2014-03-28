##Mapping vaccination data

##Read in other shapefiles
require(sp)
require(rgdal)
SACOGOutline <- readOGR("../Sacramento/SACOGData", "PlanningArea")
#Cities <- readOGR("../Sacramento/SACOGData", "Cities")
#Counties <- readOGR("../Sacramento/SACOGData", "Counties")

##Make SPDF from child care data
ChildCareDataSub <- subset(ChildCareData, !is.na(ChildCareData$Address))
CCcoord <- cbind(ChildCareDataSub$lon, ChildCareDataSub$lat)
ChildCareData_spdf <- SpatialPointsDataFrame(CCcoord, ChildCareDataSub, proj4string=CRS("+proj=longlat"))
ChildCareData_spdf <- spTransform(ChildCareData_spdf, CRS=CRS(proj4string(SACOGOutline)))

##Make SPDF from kindergarten data, removing schools with no location and those outside SACOG area
KinderDataSub <- subset(KinderData, !is.na(KinderData$Street))
KinderDataSub <- KinderDataSub[c(-36,-52,-53,-65,-68,-275),]
Kcoord <- cbind(KinderDataSub$lon, KinderDataSub$lat)
KinderData_spdf <- SpatialPointsDataFrame(Kcoord, KinderDataSub, proj4string=CRS("+proj=longlat"))
KinderData_spdf <- spTransform(KinderData_spdf, CRS=CRS(proj4string(SACOGOutline)))

##Test plot points, color-coded
#require(RColorBrewer)
require(classInt)
CCBreaks <- classIntervals(ChildCareData_spdf$PBEPctCalc, n=3, style="fixed", fixedBreaks=c(0,0.03,0.1,1))
#pal <- brewer.pal(3, "RdYlGn")
pal <- c("#FC5050","#F9F030","#91CF60")
CCColors <- findColours(CCBreaks, pal=rev(pal))
plot(ChildCareData_spdf, pch=19, cex=0.5, col=CCColors, axes=T, xlim=c(6675000,6840000), ylim=c(1900000,2075000))
KBreaks <- classIntervals(KinderData_spdf$PBEPctCalc, n=3, style="fixed", fixedBreaks=c(0,0.03,0.1,1))
KColors <- findColours(KBreaks, pal=rev(pal))
plot(KinderData_spdf, pch=19, cex=0.5, col=KColors, axes=T, xlim=c(6675000,6840000), ylim=c(1900000,2075000))

##Prepare for Google Maps
##Prettify output
CCVaccination <- ChildCareData_spdf
CCVaccination$PBEPctCalc <- round(CCVaccination$PBEPctCalc, 2)
CCVaccination <- CCVaccination[,c(-4,-5,-8,-10,-12,-14,-16,-18,-20,-22,-24,-26,-27)]
CCVaccination <- CCVaccination[,c(1:3,17:23,4:15)]
#require(scales)
#CCVaccination$PBEPctCalc <- percent(CCVaccination$PBEPctCalc)
names(CCVaccination) <- c("Facility Number","County","Type","License Status","Name","Address",
                          "City","State","ZIP","Phone","Total Students","Up To Date","Conditional",
                          "Permanent Medical Exemptions","Personal Belief Exemptions","DTP","Polio",
                          "MMR","HIB","HepB","Varicella","Pct Personal Belief Exemptions")
KVaccination <- KinderData_spdf
KVaccination$PBEPctCalc <- round(KVaccination$PBEPctCalc, 2)
KVaccination <- KVaccination[,c(-2,-4,-5,-6,-9,-11,-13,-15,-17,-19,-21,-23,-25,-26,-28,-37,-38,-39,-40,-41)]
KVaccination <- KVaccination[,c(1,14,2,16,15,17,18,20,19,21,3:13)]
names(KVaccination) <- c("School Code","County","Type","School","District","Address",
                          "City","State","ZIP","Phone","Total Kindergarteners","Up To Date","Conditional",
                          "Permanent Medical Exemptions","Personal Belief Exemptions","DTP","Polio",
                          "MMR","HepB","Varicella","Pct Personal Belief Exemptions")
##Plot
require(plotGoogleMaps)
#ic <- iconlabels(CCVaccination$Pct.Personal.Belief.Exemptions)
VaccMap <- plotGoogleMaps(CCVaccination, zcol="Pct Personal Belief Exemptions", add=T, mapTypeId="HYBRID", colPalette=c("#91CF60","#F9F030","#FC5050"), at=c(0,0.03,0.1,1), layerName="Child Care Facilities 2012-13")
plotGoogleMaps(KVaccination, zcol="Pct Personal Belief Exemptions", previousMap=VaccMap, mapTypeId="HYBRID", colPalette=c("#91CF60","#F9F030","#FC5050"), at=c(0,0.03,0.1,1), layerName="Kindergartens 2012-13")
#bubbleGoogleMaps(ChildCareData_spdf, zcol="PBEPctCalc", mapTypeId="ROADMAP", colPalette=c("#91CF60","#F9F030","#FC5050"), layerName="Child Care Facilities")

##NOTE!!!! Manually edited code in HTML file at this point,
##defining getCircle functions used below and removing extraneous legend.

##Change map markers
SacVaccination <- readLines('KVaccination.htm')
SacVaccination <- gsub("icon: new google.*F9F030.*", " icon: getCircleYellow(),", SacVaccination)
SacVaccination <- gsub("icon: new google.*91CF60.*", " icon: getCircleGreen(),", SacVaccination)
SacVaccination <- gsub("icon: new google.*FC5050.*", " icon: getCircleRed(),", SacVaccination)
fileCon <- file("SacVaccination.htm")
writeLines(SacVaccination, fileCon)
close(fileCon)
