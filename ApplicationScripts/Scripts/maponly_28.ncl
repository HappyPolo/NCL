;================================================;
;  maponly_28.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing all the counties in the U.S.
;   - Drawing specific map areas in a given color.
;   - Drawing updated counties in Colorado
;=================================================;
; This script shows how the Broomfield and 
; surrounding counties in Colorado were updated in 
; NCL V6.4.0
;=================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("png","maponly") ; send graphics to PNG file

  ncl_version                = get_ncl_version()

  mpres                      = True
  mpres@gsnMaximize          = True
  mpres@mpFillOn             = False

  mpres@tiMainFontHeightF    = 0.013

;---Set up the drawing of county boundaries.
  mpres@mpOutlineBoundarySets = "AllBoundaries"
  mpres@mpDataBaseVersion     = "MediumRes"
  mpres@mpDataSetName         = "Earth..4"

;---Zoom in on Colorado
  mpres@mpLimitMode           = "LatLon"
  mpres@mpMinLatF             =   39.5
  mpres@mpMaxLatF             =   40.5
  mpres@mpMinLonF             = -105.5
  mpres@mpMaxLonF             =  -104.5

  mpres@mpGridAndLimbOn       = False
  mpres@mpPerimOn             = True

  mpres@pmTickMarkDisplayMode = "Always"    ; Nicer tickmarks

  mpres@tiMainString = "~F22~Colorado map (NCL Version " + ncl_version + ")"

;  mpres@tiMainString = "~F22~Colorado map (NCL Version 6.4.0)"

  map = gsn_csm_map(wks,mpres)
  
;---Select certain counties by name and fill them in specific colors
  counties = (/"Boulder", "Adams", "Jefferson", "Weld", \
               "Broomfield", "Denver", "Arapahoe" /)
  colors   = (/ "green", "blue", "yellow", "red", \
                "brown", "purple", "orange" /)
  ncounties = dimsizes(counties)

  mpres@mpFillOn              = True
  mpres@mpOutlineBoundarySets = "GeophysicalAndUSStates"
  mpres@mpFillAreaSpecifiers  = counties
  mpres@mpSpecifiedFillColors = colors
  mpres@tiMainString          = ncounties + " counties filled in different colors (NCL Version " \
                                + ncl_version + ")"

;  mpres@tiMainString          = "" + ncounties + " counties filled in different colors (NCL Version 6.4.0)"

  map = gsn_csm_map(wks,mpres)
end

