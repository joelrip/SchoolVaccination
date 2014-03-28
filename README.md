SchoolVaccination
=================

Mapping school vaccination rates in Sacramento area.
----------------------------------------------------

This is a GIS visualization of immunization rates in Sacramento area child care facilities and schools, focusing particularly on children not immunized due to personal belief exemptions (PBEs).  This project covers only the six counties of the SACOG region--Sacramento, Yolo, Placer, El Dorado, Yuba, and Sutter.

Immunization information was downloaded from the California Department of Public Health (http://www.cdph.ca.gov/) in March 2014.  Specifically, the project uses data from this page: http://www.cdph.ca.gov/programs/immunize/Pages/ImmunizationLevels.aspx

Files downloaded were:  
http://www.cdph.ca.gov/programs/immunize/Documents/2012-2013%20CA%20Child%20Care%20Data.xls  
http://www.cdph.ca.gov/programs/immunize/Documents/2012-2013%20California%20Kindergarten%20Data.xls

Prior to processing the data in R, several header and footer rows were manually removed, column names were shortened, and the files were saved in CSV format as 1213ChildCare.csv and 1213Kindergarten.csv.

As the immunization data did not contain addresses, these were obtained from the California Department of Social Services (for child care facilities) and the California Department of Education (for schools).

Child care facility addresses were downloaded by selecting "Child Care Center" at this page: http://www.ccld.ca.gov/docs/ccld_search/ccld_search.aspx
then selecting and downloading each of the six counties in CSV format.  The six downloaded files were manually merged into one.  A great deal of pre-processing was necessary, as facility addresses were encoded in the file in multiple columns that varied by the length of the address (that is, long addresses spread across more columns than short addresses, and facility information frequently did not line up with column headers).  Extraneous cells were deleted in all applicable rows, so that columns lined up neatly.

Public school addresses were downloaded from this page: http://www.cde.ca.gov/ds/si/ds/pubschls.asp  
Private school addresses were downloaded from this page: http://www.cde.ca.gov/ds/si/ps/  
In both cases XLS files were downloaded for the 2012-13 school year, and preprocessing was performed to remove commas from any cells in which they occurred.  Column headers in the private school file were altered to make them easier to read in R, and extraneous header rows were removed.  Files were saved in CSV format as pubschls.csv and privateschools1213.csv.

CSV files were then imported into R using the scripts found in FileImporting.R.  These scripts further cleaned the data, merged immunization data with address data, and geocoded addresses.  Merging files revealed that 73 out of 646 child care facilities and 20 out of 522 Kindergartens did not have address information in the downloaded files.  These facilities are excluded from this analysis.  Files produced from these scripts are ChildCareData.csv and KinderData.csv, with those facilities without addresses included in the separate files ChildCareNoAdd.csv and KinderNoAdd.csv.

The data were then mapped using the scripts in MapVaccinationData.R.  Files were transformed into Spatial Points Data Frames using the sp() package.  Projections were transformed to match the projections used by local governments in their publicly available shapefiles (SACOGOutline was used here, which is available at: http://www.sacog.org/mapping/clearinghouse/), but these ended up not being used, as the final product was imported into Google Maps.  Column names were made more comprehensible, and extraneous columns were removed.  The maps were then produced using the plotGoogleMaps() package.

Note that plotGoogleMaps() defaults to using Google's pins as map icons.  To replace these, the HTML file produced by plotGoogleMaps() was manually edited to add functions to produce more generic (and less obtrusive) circles.  Specifically, the following code was added to the HTML file:

```
  function getCircleYellow() {  
    return {  
      path: google.maps.SymbolPath.CIRCLE, 
      fillColor: '#F9F030',  
      fillOpacity: 1,  
      scale: 6,  
      strokeColor: 'black',  
      strokeWeight: 1  
    };  
  }  
  
  function getCircleGreen() {  
    return {  
      path: google.maps.SymbolPath.CIRCLE,  
      fillColor: '#91CF60',  
      fillOpacity: 1,  
      scale: 6,  
      strokeColor: 'black',  
      strokeWeight: 1  
    };  
  } 
  
  function getCircleRed() {  
    return {  
      path: google.maps.SymbolPath.CIRCLE,  
      fillColor: '#FC5050',  
      fillOpacity: 1,  
      scale: 6,  
      strokeColor: 'black',  
      strokeWeight: 1  
    };  
  }  
```

Manual editing was also peformed to remove a duplicate legend, as plotGoogleMaps() produces a legend for each dataset mapped, and the legends for child care facilities and Kindergartens were identical.

The resulting HTML file was re-read into R using the final script in MapVaccinationData.R, and all references to the standard Google pins were replaced with references to the getCircle functions listed above.

The final output file is SacVaccination.htm.  In order to properly display the legend, Legend9cf882f981.png must be downloaded as well.
