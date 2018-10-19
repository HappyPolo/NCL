;*************************************************
; color_14.ncl
;
; Concepts illustrated:
;   - Drawing grayscale filled contours
;   - Setting a black background/white foreground
;
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","color")              ; open a ps file

  res                      = True               ; plot mods desired
  res@cnFillOn             = True               ; turn on color fill
  res@cnFillPalette        = "gsltod"           ; choose color map
                                                ; grayscale, light-to-dark

  res@tiMainString         = "white background, black foreground"
  plot = gsn_csm_contour_map(wks,u, res)        ; create plot

;---Set the workstation background/foreground colors to black/white.
  setvalues wks            
    "wkForegroundColor" : (/1.,1.,1./) 
    "wkBackgroundColor" : (/0.,0.,0./)  
  end setvalues

  res@tiMainString         = "black background, white foreground"
  plot = gsn_csm_contour_map(wks,u, res)     ; create plot
end
