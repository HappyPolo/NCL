;*************************************************
; mask_1.ncl
;
; Concepts illustrated:
;   - Using "mask" to set land or ocean values in your data to missing
;   - Masking the ocean in a map plot
;   - Masking land in a map plot
;   - Spanning part of a color map for contour fill
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
  oro = in->ORO(0,:,:)

;************************************************
; use mask function to mask out land and then ocean data
; ocean=0,land=1,sea_ice=2
;************************************************
  land_only  = ts                               ; trick to keep cv's and atts
  ocean_only = ts

  land_only  = mask(ts,oro,1)   ; Return the values of ts where oro=1
  ocean_only = mask(ts,oro,0)   ; Return the values of ts where oro=0

;************************************************
; common resources
;************************************************
  wks = gsn_open_wks("png","mask")                  ; send graphics to PNG file

  cmap = read_colormap_file("BlAqGrYeOrRe")         ; read colormap file

  res                      = True     ; plot mods desired
  res@cnFillOn             = True     ; turn on color fill
  res@cnLinesOn            = False    ; turn off contour lines
  res@cnFillPalette        = cmap(10:96,:)

;************************************************
; individual plots
;************************************************
  res@cnLevelSpacingF         = 3                ; interval
  res@lbLabelStride           = 4                ; every 4th label
  res@mpLandFillColor         = "white"          ; make land borders white
  res@tiMainString            = "Land Only"      ; title
  plot = gsn_csm_contour_map(wks,land_only,res)

  res@cnLevelSpacingF         = 2                ; interval
  res@lbLabelStride           = 2                ; every 2nd label
  res@mpLandFillColor         = "white"          ; make land white
  res@tiMainString            = "Ocean Only"     ; title
  plot = gsn_csm_contour_map(wks,ocean_only,res) 
end




