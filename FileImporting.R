##Import and clean Child Care data
childcare <- read.csv("Data/1213ChildCare.csv", stringsAsFactors=F)
names(childcare) = sub("X.","",names(childcare)) 
names(childcare) = sub("\\.","",names(childcare)) 
childcare$County <- gsub("\\'","",childcare$County)
childcare$Type <- gsub("\\'","",childcare$Type)
childcare$City <- gsub("\\'","",childcare$City)
childcare$Name <- gsub("\\'","",childcare$Name)
childcaresac <- childcare[(childcare$County=="SACRAMENTO")|(childcare$County=="PLACER")|(childcare$County=="EL DORADO")|(childcare$County=="YOLO")|(childcare$County=="YUBA")|(childcare$County=="SUTTER"),]
childcaresac$PBEPctCalc <- childcaresac$PBETot / childcaresac$Total

##Import and clean Child Care address data
childcareadd <- read.csv("Data/ChildCareFacilityAddresses.csv", stringsAsFactors=F)
names(childcareadd) = sub("X.","",names(childcareadd)) 
names(childcareadd) = sub("\\.","",names(childcareadd)) 
for(i in 1:9) {
  childcareadd[,i] <- gsub("\\'","",childcareadd[,i])
}
childcareadd$FacNum <- as.integer(childcareadd$FacNum)
childcareadd$Capacity <- as.integer(childcareadd$Capacity)
childcareadd$Zipcode <- as.integer(childcareadd$Zipcode)

##Merge vaccination data and address data
childcareadd <- childcareadd[order(childcareadd$FacNum),]
childcaresac <- childcaresac[order(childcaresac$FacNum),]
ChildCareData <- merge(childcaresac, childcareadd, by="FacNum", all.x=T)
ChildCareNoAdd <- subset(ChildCareData, is.na(ChildCareData$Address))
write.csv(ChildCareNoAdd, file="Data/ChildCareNoAdd.csv")
write.csv(ChildCareData, file="Data/ChildCareData.csv")

##Geocode Child Care addresses
require(ggmap)
for(j in 1:nrow(ChildCareData)) {
  if(!is.na(ChildCareData$Address[j])) {
    TempGeo <- geocode(paste(ChildCareData$Address[j],ChildCareData$City.y[j],ChildCareData$State[j],ChildCareData$Zipcode[j]))
    ChildCareData$lon[j] <- TempGeo$lon
    ChildCareData$lat[j] <- TempGeo$lat 
  } else {
    ChildCareData$lon[j] <- NA
    ChildCareData$lat[j] <- NA
  }
}