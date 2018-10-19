;================================================;
;  maponly_10.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing all the counties in the U.S.
;   - Drawing all the counties in the U.S. named "Adams"
;   - Drawing just the counties of Florida
;   - Turning off the map lat/lon grid lines
;
;=================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("png","maponly") ; send graphics to PNG file

  mpres                      = True
;  mpres@gsnMaximize          = True
  mpres@mpFillOn             = False

;
; These next three resources set up the drawing of county boundaries.
;
  mpres@mpOutlineBoundarySets = "AllBoundaries"
  mpres@mpDataBaseVersion     = "MediumRes"
  mpres@mpDataSetName         = "Earth..2"

  mpres@mpGridAndLimbOn       = False
  mpres@mpPerimOn             = True

  mpres@mpLimitMode           = "LatLon"
  mpres@mpMinLatF             =   25.
  mpres@mpMaxLatF             =   50.
  mpres@mpMinLonF             = -130.
  mpres@mpMaxLonF             =  -60. 

  mpres@tiMainString          = "~F22~US with all counties outlined"

  map = gsn_csm_map(wks,mpres)
  
;
; Draw all counties in the United States that have the name "Adams".
;
  mpres@mpOutlineBoundarySets = "GeophysicalAndUSStates"
  mpres@mpOutlineSpecifiers   = "Adams"
  mpres@tiMainString          = "~F22~US with Adams counties outlined"
  map = gsn_csm_map(wks,mpres)

;
; List of Florida counties.
;
  florida_counties = \
             (/"Alachua", "Baker", "Bay", "Bradford", "Brevard", \
               "Broward", "Calhoun", "Charlotte", "Citrus", "Clay", \
               "Collier", "Columbia", "De Soto", "Dixie", "Duval", \
               "Escambia", "Flagler", "Franklin", "Gadsden", \
               "Gilchrist", "Glades", "Gulf", "Hamilton", "Hardee", \
               "Hendry", "Hernando", "Highlands", "Hillsborough", \
               "Holmes", "Indian River", "Jackson", "Jefferson", \
               "Keys", "Lafayette", "Lake", "Lee", "Leon", "Levy", \
               "Liberty", "Madison", "Manatee", "Marion", "Martin", \
               "Miami-Dade", "Monroe", "Nassau", "Okaloosa", \
               "Okeechobee", "Orange", "Osceola", "Palm Beach", \
               "Pasco", "Pinellas", "Polk", "Putnam", "Saint Johns", \
               "Saint Lucie", "Saint Vincent Island", "Santa Rosa", \
               "Sarasota", "Seminole", "Sumter", "Suwannee", "Taylor", \
               "Union", "Volusia", "Wakulla", "Walton", "Washington" /)

;
; By putting the string "Florida . " in front of each county name, only
; those counties in Florida will get drawn. Otherwise, if any of these
; counties existed in other states, those counties would get drawn as well.
;
; Since we're zooming in on Florida, it actually wouldn't matter if the
; other similar counties were being drawn, because we 
;
  delete(mpres@mpOutlineSpecifiers)
  mpres@mpOutlineSpecifiers = "Florida . " + florida_counties
  mpres@mpMinLatF            =  25.
  mpres@mpMaxLatF            =  32.
  mpres@mpMinLonF            = -90.
  mpres@mpMaxLonF            = -80. 

  mpres@tiMainString          = "~F22~Florida and its counties outlined"

  map = gsn_csm_map(wks,mpres)

end
