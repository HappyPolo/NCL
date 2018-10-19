;*************************************************
; mask_2.ncl
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
  wks = gsn_open_wks("png","mask")                  ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrRe")         ; read colormap file


  res                      = True     ; plot mods desired
  res@cnFillOn             = True     ; turn on color fill
  res@cnLinesOn            = False    ; turn off contour lines
  res@lbLabelStride        = 4        ; every 4th label
  res@cnFillPalette        = cmap(10:96,:)

  res@cnLevelSpacingF      = 3        ; interval

  res@tiMainString         = "Draw land ON TOP of contours"      ; title

  res@cnFillDrawOrder      = "Predraw"  ; draw contours first

  plot = gsn_csm_contour_map(wks,ts,res)

end




