;***************************************************************
; climo_4.ncl
;
; Concepts illustrated:
;   - Drawing a latitude/time contour plot
;   - Calculating a zonally averaged annual cycle
;   - Setting contour colors using RGB triplets
;   - Explicitly setting tickmarks and labels on the bottom X axis
;   - Explicitly setting contour levels
;   - Transposing an array
;
;***************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************************************** 
begin
;****************************************************
; open file and read in monthly data
;****************************************************
  f    = addfile ("xieArkin-T42.nc", "r")
  P    = f->prc
;****************************************************
; use functions in contributed.ncl
;****************************************************
  Pclm  = clmMonTLL (P(0:215,:,:))     ; time must be multiple of 12
  Pzone = transpose(dim_avg_n_Wrap(Pclm,2))    ; lat x month

;******************************************
; generate colormap using rgb triplets
;******************************************
  wks   = gsn_open_wks("png","climo")        ; send graphics to PNG file

  colors = (/ (/255,255,255/), (/244,255,244/), \
              (/217,255,217/), (/163,255,163/), (/106,255,106/), \
              (/43,255,106/), (/0,224,0/), (/0,134,0/),(/255,255,0/),\
              (/255,127,0/) /) / 255.
  
;******************************************
; plot resources
;*****************************************
  res                      = True            ; plot mods desired
  
  res@cnFillOn             = True            ; turn on color

  res@cnFillPalette        = colors          ; set color map
  res@cnLinesOn            = False           ; no contour lines
  
  res@tmXBMode             = "Explicit"      ; label independently
  res@tmXBValues           = ispan(0,11,1)
  res@tmXBLabels           = (/"J","F","M","A","M","J",\
                               "J","A","S","O","N","D"/)
  
  res@tiMainString         = "Zonally Averaged Annual Cycle" 
  
  res@cnLevelSelectionMode = "ExplicitLevels"  ; set explicit contour levels
  res@cnLevels             = (/0.5,1.0,2.0,3.0,4.0,5.0,6.5,7.5/)
  
  plot = gsn_csm_lat_time(wks, Pzone, res ) 
end

