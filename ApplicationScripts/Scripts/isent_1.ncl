;**********************************************************
; isent_1.ncl
;**********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

begin
;**********************************************************
; open file and read required data
;**********************************************************
  f = addfile("atmos.nc","r")

  hya  = f->hyam                       ; hybrid coef
  hyb  = f->hybm 
  ps   = f->PS                         ; surface pressure [Pa]
  p0   = 100000.                       ; since ps is in Pa or [ f*>P0]

  T    = f->T                          ; temperature at hybrid levels
;***********************************************************
; Calculate pressure at each level at all grid points
;***********************************************************
  ph           = T                                         ; transfer meta data
  ph           = pres_hybrid_ccm (ps, p0, hya, hyb)        ; ph(ntim,klvl,nlat,mlon)
  ph@long_name = "pressure at each hybrid level"
  ph@units     = ps@units
;***********************************************************
; Calculate potential temperature at each level aat all grid points
;***********************************************************
  theta           = T                                      ; create/transfer meta data
  theta           = T*(100000/ph)^0.286                    ; calculate potential temperature
;***********************************************************
; User specified isentropic levels
;***********************************************************
  lvl           = ispan(400,240,20)*1.                     ; specify desired isentropic levels
;**********************************************************
; Read in a variable to be interpolated
;**********************************************************
  x    = f->U                                              ; zonal wind
;**********************************************************  
; use int2p to interpolate: This operates on the rightmost 
; dimension so use named dimensions to reorder
; 
; As of V5.2.0, you will be able to use int2p_n so no
; reordering is required.
;*********************************************************
  xlvl = int2p (theta(time|:,lat|:,lon|:,lev|:), \
                x(time|:,lat|:,lon|:,lev|:), lvl, 0)       

; As of V5.2.0, use this, but then xlvl will be dimensioned 
; time x level x lat x lon, so you need to change code
; below accordingly.
;  xlvl = int2p_n (theta, x, lvl, 0, 1)

;*********************************************************
; Assign meta data to the derived variable data object
;*********************************************************
; For V5.2.0 or higher
; xlvl!0    = "time"                     ; name dimensions
; xlvl!1    = "lvl"                      
; xlvl!2    = "lat"
; xlvl!3    = "lon"

  xlvl!0    = "time"                     ; name dimensions
  xlvl!1    = "lat"
  xlvl!2    = "lon"
  xlvl!3    = "lvl"
  xlvl&time =  x&time                    ; assign coordinates
  xlvl&lvl  =  lvl                       ; isentropic levels
  xlvl&lat  =  x&lat
  xlvl&lon  =  x&lon
  xlvl@long_name = x@long_name           ; attributes
  xlvl@units     = x@units
;*********************************************************
; create plot
;*********************************************************
  wks  = gsn_open_wks("png","isent")             ; send graphics to PNG file

  res                 = True                     ; plot mods desired
  res@cnFillOn        = True                     ; turn on color
  res@cnFillPalette   = "BlAqGrYeOrRe"           ; set color map
  res@cnLinesOn       = False                    ; turn off contour lines
  res@tiMainString    = "Isentropic Level of 300"; title

  plot = gsn_csm_contour_map(wks,xlvl(0,:,:,{300}),res)  

; For V5.2.0 or higher
; plot = gsn_csm_contour_map(wks,xlvl(0,{300},:,:),res)  
    
end














