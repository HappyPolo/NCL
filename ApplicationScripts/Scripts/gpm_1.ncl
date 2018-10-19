;----------------------------------------------------------------------
; gpm_1.ncl
;
; Concepts illustrated:
;   - Reading a GPM Monthly HDF5 file
;   - Reading group data off an HDF5 file using two methods
;   - Using lbBoxEndCapStyle to draw triangles at the end of a labelbar
;   - Adding labels to the left end of a labelbar
;   - Transposing dimension order (lon,lat) => (lat,lon)
;   - Explicitly setting the fill colors for contours
;   - Drawing raster contours for faster results
;   - Changing the width of a labelbar
;   - Changing the size of a PNG image
;----------------------------------------------------------------------
; This example requires at least NCL 6.3.0 to generate the first plot.
; The second two plots use a new  "lbBoxEndCapStyle" resource that
; was introduced in NCL V6.4.0.
;----------------------------------------------------------------------

begin
 file_name = "3B-MO.MS.MRG.3IMERG.20140701-S000000-E235959.07.V03D.HDF5"

;----------------------------------------------------------------------
; parse file name; done for illustration only
;----------------------------------------------------------------------

 delim = ".-"
 nf    = str_fields_count(file_name, delim)   ; there are 11 fields
 
 yyyymmdd = toint( str_get_field(file_name, 6, delim) ) 
 yyyymm   = yyyymmdd/100
 
;----------------------------------------------------------------------
; open file:specify desired variable
;----------------------------------------------------------------------

;------------------------------------------------------------
; There are two ways to read variables off a files
; containing nested groups.
;
; Method 1: 
;     - Open the group with the "=>" syntax
;     - Read the data using the usual "->" syntax
;
; Method 2:
;     - Open the variable directly using the full path 
;       to the file.
;------------------------------------------------------------
  USE_FULL_PATH = False

 f = addfile(file_name, "r")

  if(.not.USE_FULL_PATH) then
;----------------------------------------------------------------------
; Access variable in group  "/Grid" ; Note group access is via => syntax
;----------------------------------------------------------------------
    var_name = "precipitation"
    grp      = f=>/Grid
    p        = grp->$var_name$
  else  
;----------------------------------------------------------------------
; Access variable using full group path.
;----------------------------------------------------------------------
    var_name = "/Grid/precipitation"
    p        = f->$var_name$
  end if

  printVarSummary(p)

;----------------------------------------------------------------------
; create graphical resources
;----------------------------------------------------------------------
 wtype          = "png"
 wtype@wkWidth  = 1500     ; Set the pixel size of PNG image.
 wtype@wkHeight = 1500  
 wks = gsn_open_wks(wtype, "gpm")

 res                      = True
 res@gsnMaximize          = True

 res@cnFillOn             = True
 res@cnFillMode           = "RasterFill"
 res@cnLinesOn            = False
 res@cnLineLabelsOn       = False
 
 res@mpFillOn             = False
 res@mpCenterLonF         = 180
 
 res@cnLevelSelectionMode = "ExplicitLevels"
 res@cnLevels             = (/ 0.01, 0.02, 0.04, 0.08, 0.16, \
                               0.32, 0.64, 0.96/)
 res@cnFillColors         = (/"white","cyan", "green","yellow",\
                              "darkorange","red","magenta","purple",\
                              "black"/)

 res@pmLabelBarWidthF     = 0.8
 res@tiMainString         = file_name
 res@tiMainFontHeightF    = 0.018
 res@gsnLeftString        = var_name
 res@gsnCenterString      = yyyymm

;----------------------------------------------------------------------
; NCL expects (lat,lon) order for map plotting: use 'named dimension 
; reordering' to transpose the data.
;----------------------------------------------------------------------
 plot = gsn_csm_contour_map(wks, p(lat|:,lon|:), res)

;----------------------------------------------------------------------
; For the second plot, convert the two end labelbar boxes to triangles.
; This resource was introduced in NCL V6.4.0.
;----------------------------------------------------------------------
 res@lbBoxEndCapStyle = "TriangleBothEnds"
 plot = gsn_csm_contour_map(wks, p(lat|:,lon|:), res)

;----------------------------------------------------------------------
; For the third plot we'll customize the labelbar with a "hard" value
; of 0 on the left end box, and a triangle end on the right side. We
; want to keep the original labels but add a '0' label to the left
; side, so we use "getvalues" to retrieve the original labels.
;----------------------------------------------------------------------
 getvalues plot@contour
    "lbLabelStrings" : lbstrings
 end getvalues

;
; Create a new set of labelbar strings with an extra label on the left
; and the right label set to an empty string.
;
 nlb                   = dimsizes(lbstrings)
 new_lbstrings         = new(nlb+2,string)
 new_lbstrings(1:nlb)  = lbstrings
 new_lbstrings(0)      = "0"   ; Left label
 new_lbstrings(nlb+1)  = ""    ; No label on right end

 res@lbBoxEndCapStyle   = "TriangleHighEnd"
 res@cnLabelBarEndStyle = "IncludeMinMaxLabels"   ; force a label at the end of both boxes
 res@lbLabelStrings     = new_lbstrings
 plot = gsn_csm_contour_map(wks, p(lat|:,lon|:), res)
end
