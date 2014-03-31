##Import and clean Child Care data
childcare <- read.csv("Data/1314ChildCare.csv", stringsAsFactors=F)
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

##Merge child care vaccination data and address data
childcareadd <- childcareadd[order(childcareadd$FacNum),]
childcaresac <- childcaresac[order(childcaresac$FacNum),]
ChildCareData <- merge(childcaresac, childcareadd, by="FacNum")
##Multiple facility numbers are off by one - capture these
childcaresac2 <- subset(childcaresac, !(childcaresac$FacNum %in% ChildCareData$FacNum))
childcareadd$FacNum <- childcareadd$FacNum + 1
ChildCareData2 <- merge(childcaresac2, childcareadd, by="FacNum")
ChildCareData <- rbind(ChildCareData, ChildCareData2)
childcareadd$FacNum <- childcareadd$FacNum - 1
##Remove the one that's not a match
ChildCareData <- ChildCareData[-579,]
#ChildCareNoAdd <- subset(childcaresac, !(childcaresac$FacNum %in% ChildCareData$FacNum))
#write.csv(ChildCareNoAdd, file="Data/ChildCareNoAdd1314.csv")
write.csv(ChildCareData, file="Data/ChildCareData1314.csv")

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
##Fix broken addresses
ChildCareData[430,32] <- "1400 E STREET"
TempGeo <- geocode(paste(ChildCareData$Address[430],ChildCareData$City.y[430],ChildCareData$State[430],ChildCareData$Zipcode[430]))
ChildCareData$lon[430] <- TempGeo$lon
ChildCareData$lat[430] <- TempGeo$lat 
ChildCareData[477,32] <- "1101 F STREET"
TempGeo <- geocode(paste(ChildCareData$Address[477],ChildCareData$City.y[477],ChildCareData$State[477],ChildCareData$Zipcode[477]))
ChildCareData$lon[477] <- TempGeo$lon
ChildCareData$lat[477] <- TempGeo$lat 

##Import and clean Kindergarten data
kinder <- read.csv("Data/1314Kindergarten.csv", stringsAsFactors=F)
kindersac <- kinder[(kinder$COUNTY=="SACRAMENTO")|(kinder$COUNTY=="PLACER")|(kinder$COUNTY=="EL DORADO")|(kinder$COUNTY=="YOLO")|(kinder$COUNTY=="YUBA")|(kinder$COUNTY=="SUTTER"),]
kindersac$PBEPctCalc <- kindersac$PBETot / kindersac$Total

##Import and clean Kindergarten address data
kinderadd <- read.csv("Data/pubschls.csv", stringsAsFactors=F)
kinderadd$CDSCode <- as.character(kinderadd$CDSCode)
require(stringr)
kinderadd$SchCode <- str_sub(kinderadd$CDSCode, start= -7)
kinderadd$SchCode <- as.integer(kinderadd$SchCode)
kinderadd2 <- read.csv("Data/privateschools1314.csv", stringsAsFactors=F)
kinderadd2$SchCode <- str_sub(kinderadd2$CDSCode, start= -7)
kinderadd2$SchCode <- as.integer(kinderadd2$SchCode)

##Make column names and data types identical in both kindergarten address files, and merge address files
colnames(kinderadd2)[8] <- "Phone"
colnames(kinderadd2)[9] <- "District"
#colnames(kinderadd2)[13] <- "AdmFName1"
#colnames(kinderadd2)[14] <- "AdmLName1"
#colnames(kinderadd2)[16] <- "AdmEmail1"
#kinderadd2 <- kinderadd2[,c(-1,-10,-12,-15,-17,-18,-19)]
kinderadd <- kinderadd[,c(-2,-11,-12,-13,-14,-15,-16,-17)]
kinderadd2$Zip <- as.character(kinderadd2$Zip)
kinderaddall <- rbind(kinderadd,kinderadd2,stringsAsFactors=F)
kinderaddall <- kinderaddall[kinderaddall$SchCode > 0,]
kinderaddall <- kinderaddall[!is.na(kinderaddall$SchCode),]

##Merge kindergarten vaccination data and address data
kinderaddall <- kinderaddall[order(kinderaddall$SchCode),]
kindersac <- kindersac[order(kindersac$SchCode),]
KinderData <- merge(kindersac, kinderaddall, by="SchCode", all.x=T)
KinderNoAdd <- subset(KinderData, is.na(KinderData$Street))
write.csv(KinderNoAdd, file="Data/KinderNoAdd1314.csv")
write.csv(KinderData, file="Data/KinderData1314.csv")

##Geocode Kindergarten addresses
require(ggmap)
for(j in 1:nrow(KinderData)) {
  if(!is.na(KinderData$Street[j])) {
    TempGeo <- geocode(paste(KinderData$Street[j],KinderData$City[j],KinderData$State[j],KinderData$Zip[j]))
    KinderData$lon[j] <- TempGeo$lon
    KinderData$lat[j] <- TempGeo$lat 
  } else {
    KinderData$lon[j] <- NA
    KinderData$lat[j] <- NA
  }
}