;================================================
;  lb_3.ncl
;================================================
;
; Concepts illustrated:
;   - Changing the labelbar labels
;   - Changing the angle of labelbar labels
;   - Adding a title to a labelbar
;   - Changing the font size of the labelbar's labels
;   - Moving the labelbar away from the plot
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
  wks = gsn_open_wks("png","lb")               ; send graphics to PNG file

  res                  =   True
  res@cnFillOn         =   True                ; turn on color  
  res@cnFillPalette    =   "wgne15"            ; set the color map
  res@lbLabelAngleF    =    45                 ; angle labels
  res@lbLabelFontHeightF =.022                 ; make labels larger
  res@lbTitleOn        = True                  ; turn on title
  res@lbTitleString    = "Default position for label bar title"
  res@lbTitleFontHeightF= .015                 ; make title smaller
  res@pmLabelBarOrthogonalPosF = .10           ; move whole thing down


  contour = gsn_csm_contour_map_ce(wks,v(0,3,:,:),res)  ; create the plot
end
