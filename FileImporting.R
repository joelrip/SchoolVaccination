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
childcareadd <- read.csv("Data/ChildCareFacilityAddresses.csv", quote="", stringsAsFactors=F)
names(childcareadd) = sub("X..","",names(childcareadd)) 
names(childcareadd) = sub("\\..","",names(childcareadd)) 
names(childcareadd) = sub("\\..","",names(childcareadd)) 
for(i in 1:9) {
  childcareadd[,i] <- gsub("\\'","",childcareadd[,i])
}
for(i in 1:9) {
  childcareadd[,i] <- gsub("\\\\","",childcareadd[,i])
}
