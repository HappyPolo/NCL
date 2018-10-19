;================================================;
;  maponly_16.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing state and/or province boundaries for Brazil, China, and India
;
; Note: you must have NCL version 5.1.0 to run this example!
;
; This example shows how you will be able to get state and province
; divisions in Brazil, China, and India.  Other divisions have also
; been added. Documentation is not yet available.
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

begin 
  wks = gsn_open_wks("png","maponly")      ; send graphics to PNG file
  gsn_define_colormap(wks,"amwg")

  res                       = True  
  res@gsnMaximize           = True         ; Maximize plot in frame.
  res@gsnPaperOrientation   = "Portrait"

  res@pmTickMarkDisplayMode = "Always"     ; Turn on map tickmarks

  res@mpDataSetName         = "Earth..4"   ; This new database contains
                                           ; divisions for other countries.
  res@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database

  res@mpOutlineOn           = True         ; Turn on map outlines
  res@mpOutlineSpecifiers   = (/"Brazil:states","China:states","India:states"/)

  res@mpFillOn              = True         ; Turn on map fill
  res@mpFillBoundarySets    = "National"
  res@mpFillAreaSpecifiers  = (/"Brazil:states","China:states","India:states"/)

  res@tiMainFont            = "helvetica"
  res@tiMainOffsetYF        = -0.02
  res@tiMainFontHeightF     = 0.02

  res@tiMainString          = "States of Brazil"
  res@mpMaxLatF             =  15          ;  South America limits 
  res@mpMinLatF             = -57
  res@mpMaxLonF             = 330
  res@mpMinLonF             = 270

  plot = gsn_csm_map(wks,res)

  res@tiMainString          = "Provinces of China"
  res@mpMinLatF             =  17          ; Asia limits
  res@mpMaxLatF             =  55
  res@mpMinLonF             =  72
  res@mpMaxLonF             = 136

  plot = gsn_csm_map(wks,res)

  res@tiMainString          = "States of India"
  res@mpMinLatF             =   6         ; India limits
  res@mpMaxLatF             =  38
  res@mpMinLonF             =  65
  res@mpMaxLonF             = 100

  plot = gsn_csm_map(wks,res)
end 
