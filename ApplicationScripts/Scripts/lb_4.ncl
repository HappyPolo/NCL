;================================================
;  lb_4.ncl
;================================================
;
; Concepts illustrated:
;   - Changing the labelbar labels
;   - Adding a title to a labelbar
;   - Changing the font of the labelbar's labels
;   - Making the labelbar label fonts smaller
;   - Centering the labels inside each box in a labelbar
;   - Adding a vertical title to a labelbar
;
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; open netCDF file and read in data
;************************************************
  in = addfile("atmos.nc","r")
  v  = in->V
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lb")           ; send graphics to PNG file

  res                  =  True
  res@cnFillOn         =  True                ; turn on color  
  res@cnFillPalette    =  "wgne15"            ; set color map
  res@lbTitleOn        =  True                ; turn on title
  res@lbTitleString    = "m/s"                ; title string
  res@lbTitlePosition  = "Right"              ; title position
  res@lbTitleFontHeightF= .015                ; make title smaller
  res@lbTitleDirection = "Across"             ; title direction

  res@lbLabelFont      = "Helvetica-Bold"     ; label font
  res@lbLabelPosition  = "Center"             ; label position
  res@lbLabelAlignment = "BoxCenters"         ; label orientation
  res@lbLabelStrings =  (/"1","2","3","4","5","6","7","8",\
        "9","10","11","12","13"/) 

  contour = gsn_csm_contour_map_ce(wks,v(0,3,:,:),res)  ; create the plot
end
