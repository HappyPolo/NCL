;*************************************************
; resize_4.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; read July zonal winds
  v = a->V(1,:,:)
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("png","resize")                ; send graphics to PNG file
  
  res                     = True
  res@cnFillOn            = True                    ; turn on color
  res@cnFillPalette       = "BlAqGrYeOrReVi200"     ; set color map
  res@cnLinesOn           = False                   ; turn off contour lines
  
; to have a common label bar, both plots should be set to the same interval
; b/c the label bar is drawn by default from the interval of the first plot.
  res@cnLevelSelectionMode =  "ManualLevels"   
  res@cnMinLevelValF       = -10.
  res@cnMaxLevelValF       =  45.
  res@cnLevelSpacingF      =   5.
  
; allow ncl to choose landcape or portrait. You can also force by 
; setting to "landscape" or "portrait".
  
  res@gsnPaperOrientation = "auto"          
  res@gsnMaximize         = True        ; must include w/ Paper Orientation
  
  plot  = gsn_csm_contour_map_ce(wks,u,res) 
  
end


