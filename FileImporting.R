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

##Merge child care vaccination data and address data
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
##Fix broken address
ChildCareData[579,32] <- "1101 F STREET"
TempGeo <- geocode(paste(ChildCareData$Address[579],ChildCareData$City.y[579],ChildCareData$State[579],ChildCareData$Zipcode[579]))
ChildCareData$lon[579] <- TempGeo$lon
ChildCareData$lat[579] <- TempGeo$lat 

##Import and clean Kindergarten data
kinder <- read.csv("Data/1213Kindergarten.csv", stringsAsFactors=F)
kindersac <- kinder[(kinder$COUNTY=="SACRAMENTO")|(kinder$COUNTY=="PLACER")|(kinder$COUNTY=="EL DORADO")|(kinder$COUNTY=="YOLO")|(kinder$COUNTY=="YUBA")|(kinder$COUNTY=="SUTTER"),]
kindersac$PBEPctCalc <- kindersac$PBETot / kindersac$Total

##Import and clean Kindergarten address data
kinderadd <- read.csv("Data/pubschls.csv", stringsAsFactors=F)
kinderadd$CDSCode <- as.character(kinderadd$CDSCode)
require(stringr)
kinderadd$SchCode <- str_sub(kinderadd$CDSCode, start= -7)
kinderadd$SchCode <- as.integer(kinderadd$SchCode)
kinderadd2 <- read.csv("Data/privateschools1213.csv", stringsAsFactors=F)
kinderadd2$SchCode <- str_sub(kinderadd2$CDSCode, start= -7)
kinderadd2$SchCode <- as.integer(kinderadd2$SchCode)

##Make column names and data types identical in both kindergarten address files, and merge address files
colnames(kinderadd2)[9] <- "Phone"
colnames(kinderadd2)[11] <- "District"
colnames(kinderadd2)[13] <- "AdmFName1"
colnames(kinderadd2)[14] <- "AdmLName1"
colnames(kinderadd2)[16] <- "AdmEmail1"
kinderadd2 <- kinderadd2[,c(-1,-10,-12,-15,-17,-18,-19)]
kinderadd <- kinderadd[,c(-2,-11,-12,-13,-14)]
kinderadd2$Zip <- as.character(kinderadd2$Zip)
kinderaddall <- rbind(kinderadd,kinderadd2,stringsAsFactors=F)
kinderaddall <- kinderaddall[kinderaddall$SchCode > 0,]
kinderaddall <- kinderaddall[!is.na(kinderaddall$SchCode),]

##Merge kindergarten vaccination data and address data
kinderaddall <- kinderaddall[order(kinderaddall$SchCode),]
kindersac <- kindersac[order(kindersac$SchCode),]
KinderData <- merge(kindersac, kinderaddall, by="SchCode", all.x=T)
KinderNoAdd <- subset(KinderData, is.na(KinderData$Street))
write.csv(KinderNoAdd, file="Data/KinderNoAdd.csv")
write.csv(KinderData, file="Data/KinderData.csv")

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