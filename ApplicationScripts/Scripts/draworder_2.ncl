;*************************************************
; draworder_2.ncl
;
; Concepts illustrated:
;   - Using draw order resources to mask areas in a plot
;   - Drawing filled land areas on top of a contour plot
;
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
  in = addfile("atmos.nc","r")
  ts = in->TS(0,:,:)
;************************************************
; common resources
;************************************************
  wks = gsn_open_wks("png","draworder")             ; send graphics to PNG file


  res                      = True     ; plot mods desired

  res@gsnMaximize          = True     ; maximize plot

  res@cnFillOn             = True     ; turn on color fill
  res@cnLinesOn            = False    ; turn of contour lines
  res@lbLabelStride        = 4        ; every 4th label

  res@cnLevelSpacingF      = 3        ; interval
  res@cnFillPalette        = "BlAqGrYeOrRe" ; set color map

  res@tiMainString         = "Default: draw filled contours on top of map"

  plot = gsn_csm_contour_map_ce(wks,ts,res)

  res@tiMainString         = "Draw land on top of contours"
  res@cnFillDrawOrder      = "PreDraw"  ; draw contours first
  res@cnFillPalette        = "BlAqGrYeOrRe" ; set color map
  plot = gsn_csm_contour_map_ce(wks,ts,res)

end




