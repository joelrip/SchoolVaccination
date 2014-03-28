SchoolVaccination
=================

Mapping school vaccination rates in Sacramento area.

This is a GIS visualization of immunization rates in Sacramento area child care facilities and schools, focusing particularly on children not immunized due to personal belief exemptions (PBEs).  This project covers only the six counties of the SACOG region--Sacramento, Yolo, Placer, El Dorado, Yuba, and Sutter.

Immunization information was downloaded from the California Department of Public Health (http://www.cdph.ca.gov/) in March 2014.  Specifically, immunization information was downloaded from this page: http://www.cdph.ca.gov/programs/immunize/Pages/ImmunizationLevels.aspx

Files downloaded were:
http://www.cdph.ca.gov/programs/immunize/Documents/2012-2013%20CA%20Child%20Care%20Data.xls
http://www.cdph.ca.gov/programs/immunize/Documents/2012-2013%20California%20Kindergarten%20Data.xls

Prior to processing the data in R, several header and footer rows were manually removed, column names were shortened, and the files were saved in CSV format as 1213ChildCare.csv and 1213Kindergarten.csv.

As the immunization data did not contain addresses, these were obtained from the California Department of Social Services (for child care facilities) and the California Department of Education (for schools).

Child care facility addresses were downloaded by selecting "Child Care Center" at this page: http://www.ccld.ca.gov/docs/ccld_search/ccld_search.aspx
Then selecting and downloading each of the six counties in CSV format.  The six downloaded files were manually merged into one.  A great deal of pre-processing was necessary, as facility addresses were encoded in the file in multiple columns that varied by the length of the address (that is, long addresses spread across more columns than short addresses, and facility information frequently did not line up with column headers).  Extraneous cells were deleted in all applicable rows, so that columns lined up neatly.

Public school addresses were downloaded from this page: http://www.cde.ca.gov/ds/si/ds/pubschls.asp
Private school addresses were downloaded from this page: http://www.cde.ca.gov/ds/si/ps/
In both cases XLS files were downloaded for the 2012-13 school year, and preprocessing was performed to remove commas from any cells in which they occurred.  Column headers in the private school file were altered to make them easier to read in R, and extraneous header rows were removed.  Files were saved in CSV format as pubschls.csv and privateschools1213.csv.
