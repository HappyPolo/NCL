;************************************
; coast_2.ncl
;************************************
;
; Concepts illustrated:
;   - Drawing a Lambert Conformal map using high resolution map outlines
;   - Drawing a map using the high resolution map outlines
;   - Zooming in on a particular area on a Lambert Conformal map
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Send output to a PNG file
;
  wks = gsn_open_wks("png","coast")
;
; Set up some map resources.
;
  mpres                       = True
  mpres@gsnMaximize           = True

  mpres@mpOutlineOn           = True
  mpres@mpProjection          = "LambertConformal"
  mpres@mpLimitMode           = "LatLon"
  mpres@mpMinLonF             = -15.
  mpres@mpMaxLonF             =  15
  mpres@mpMinLatF             =  40.
  mpres@mpMaxLatF             =  70.

;
; Note: in order to use the high-resolution coastal database
; (mpDataBaseVersion = "HighRes"), you must download and install RANGS
; (Regionally Accessible Nested Global Shorelines), the multi-resolution
; coastline database, developed by Rainer Feistel from Wessel and
; Smith's GSHHS (Global Self-consistent Hierarchical High-resolution
; Shoreline) database. For more information, visit:
;
;    http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml
;
; If you don't have this database, or don't want to install it, 
; change this resource value to "MediumRes".
;
  mpres@mpDataBaseVersion     = "HighRes"    ; Use the high-res database

  mpres@pmTickMarkDisplayMode = "Always"     ; Turn on map tickmarks.

  mpres@tiMainString          = "Using the RANGS-GSHHS coastal database"
;
; Draw a lambert conformal map, with the above resources set.
;
  map = gsn_csm_map(wks,mpres)

end
