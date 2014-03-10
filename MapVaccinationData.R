##Mapping vaccination data

##Read in other shapefiles
require(sp)
require(rgdal)
SACOGOutline <- readOGR("../Sacramento/SACOGData", "PlanningArea")
Cities <- readOGR("../Sacramento/SACOGData", "Cities")
Counties <- readOGR("../Sacramento/SACOGData", "Counties")

##Make SPDF from child care data
ChildCareDataSub <- subset(ChildCareData, !is.na(ChildCareData$Address))
CCcoord <- cbind(ChildCareDataSub$lon, ChildCareDataSub$lat)
ChildCareData_spdf <- SpatialPointsDataFrame(CCcoord, ChildCareDataSub, proj4string=CRS("+proj=longlat"))
ChildCareData_spdf <- spTransform(ChildCareData_spdf, CRS=CRS(proj4string(SACOGOutline)))

##Plot points, color-coded
#require(RColorBrewer)
require(classInt)
CCBreaks <- classIntervals(ChildCareData_spdf$PBEPctCalc, n=3, style="fixed", fixedBreaks=c(0,0.03,0.1,1))
#pal <- brewer.pal(3, "RdYlGn")
pal <- c("#FC5050","#F9F030","#91CF60")
CCColors <- findColours(CCBreaks, pal=rev(pal))
plot(ChildCareData_spdf, pch=19, cex=0.5, col=CCColors, axes=T, xlim=c(6675000,6840000), ylim=c(1900000,2075000))

##Put in Google Maps
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
#Plot
require(plotGoogleMaps)
ic <- iconlabels(CCVaccination$Pct.Personal.Belief.Exemptions)
plotGoogleMaps(CCVaccination, zcol="Pct Personal Belief Exemptions", mapTypeId="ROADMAP", colPalette=c("#91CF60","#F9F030","#FC5050"), at=c(0,0.03,0.1,1), layerName="Child Care Facilities 2012-13")
#bubbleGoogleMaps(ChildCareData_spdf, zcol="PBEPctCalc", mapTypeId="ROADMAP", colPalette=c("#91CF60","#F9F030","#FC5050"), layerName="Child Care Facilities")
