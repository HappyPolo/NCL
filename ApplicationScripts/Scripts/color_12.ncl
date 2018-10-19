;***********************************************
; color_12.ncl
;
; Concepts illustrated:
;   - Creating a color map using RGB triplets
;   - Explicitly setting contour levels to uneven levels
;   - Creating a color map to match the number of contour levels
;
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;************************************************
; Read the file
;************************************************
  a    = addfile("xieArkin-T42.nc","r")
  prc  = a->prc                                 ; read in data
;************************************************
; create colors
;*************************************************
  wks = gsn_open_wks("png","color")             ; open a workstation and send data to PNG
 
  colors = (/ (/255,255,255/), (/244,255,244/), \
              (/217,255,217/), (/163,255,163/), (/106,255,106/), \
              (/43,255,106/), (/0,224,0/), (/0,134,0/),(/255,255,0/),\
              (/255,127,0/) /) / 255.   ; be sure to make this a float!

;************************************************
; create panel plots
;*************************************************
  res                      = True               ; plot options desired

  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnFillPalette        = colors

  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels             = (/0.1,0.2,0.4,0.8,1.6,3.2,6.4,12.8,25.6/)


  res@mpFillOn             = False              ; turn off gray continents
 
  res@mpMaxLatF            =   0.               ; zoom in over Australia
  res@mpMinLatF            = -50.
  res@mpMaxLonF            =  170
  res@mpMinLonF            =  100.

  res@tiMainString         = "A good precip colormap" 

  plot = gsn_csm_contour_map(wks,prc(0,:,:), res)  ; create plot
end






