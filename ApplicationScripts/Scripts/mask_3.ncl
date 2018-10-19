;*************************************************
; mask_3.ncl
;
; Concepts illustrated:
;   - Using "mask" to set a range of values in your data to missing
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
; use mask function to mask out a range of the data 
;************************************************
  range_only  = ts                               ; trick to keep cv's and atts
  range_only  = mask(ts,(ts.ge.279),True)
;************************************************
; common resources
;************************************************
  wks = gsn_open_wks("png","mask")                   ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrRe")          ; read colormap file

  res                      = True     ; plot mods desired
  res@cnFillOn             = True     ; turn on color fill
  res@cnLinesOn            = False    ; turn off contour lines
  res@cnFillPalette        = cmap(10:96,:)

  res@cnLevelSelectionMode    = "ManualLevels"   ; manual levels
  res@cnMinLevelValF          = 219              ; min level
  res@cnMaxLevelValF          = 310              ; max level
  res@cnLevelSpacingF         = 3                ; interval

  res@mpLandFillColor         = "white"          ; set land color
  res@lbLabelStride           = 4                ; every 4th label
  res@tiMainString            = "Range Only"     ; title
  plot = gsn_csm_contour_map(wks,range_only,res)

 
end




