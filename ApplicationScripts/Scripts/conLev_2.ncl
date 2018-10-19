; ===========================================
; conLev_2.ncl
;
; Concepts illustrated:
;   - Setting the maximum number of contour levels allowed
;   - Explicitly setting the fill colors for land, ocean, and inland water
;   - Adding attributes to a variable
;   - Using "getvalues" to retrieve resource values;
; ===========================================
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

begin
  f      = addfile ("b003_TS_200-299.nc", "r")
  x      = f->TS(15,:,:)       ; Grab 15th timestep (=year 15), lowest sigma level (=17)

  x = x-273.15			  ; convert from Kelvin->Celsius
  x@units = "C"

  wks = gsn_open_wks("png","conLev")             ; send graphics to PNG file

  res              = True
  res@gsnMaximize  = True                        ; maximize plot in frame
;
; Draw 20 equally spaced contours between min(x)+CI and max(x)-CI.
; CI = contour interval calculated by NCL
;
  res@cnMaxLevelCount      = 20
  res@cnLevelSelectionMode = "EqualSpacedLevels" ; equally spaced contour levels

  res@mpFillOn     = True                        ; turn on map fill
  res@mpFillColors = (/ "transparent","transparent",\
                        "gray","transparent"/)   ; color the continents gray
  plot = gsn_csm_contour_map(wks,x,res)    

;---To retrieve the levels NCL used, use "getvalues"
  getvalues plot@contour
    "cnLevels" : levels
  end getvalues
  print("levels = " + levels)

end     
