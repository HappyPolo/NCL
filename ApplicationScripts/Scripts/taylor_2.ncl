;**********************************
; taylor_2.ncl
;**********************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;
; This file still has to be loaded manually 
load "./taylor_diagram.ncl"
;**********************************
begin
;**********************************
; create some dummy data. ;
; All ratio values must be between 0 and 1.65
; All cross correlation values are 0.0 to 1.0 [inclusive]
;**********************************

; "p" dataset                      
  p_rat    = (/0.60, 0.50, 0.45, 0.75, 1.15/)
  p_cc     = (/0.24, 0.75, 1.00, 0.93, 0.37/)

; "t" dataset
  t_rat    = (/0.75, 0.64, 0.40, 0.85, 1.15 /)
  t_cc     = (/0.24, 0.75, 0.47, 0.88, 0.73/)

;**********************************
; Put the ratios and pattern correlations into
; arrays for plotting
;**********************************

  nDataSets  = 2                               ; number of datasets
  npts       = dimsizes(p_rat)
  ratio      = new ((/nDataSets, npts/),typeof(p_rat) )
  cc         = new ((/nDataSets, npts/),typeof(p_cc ) )

  ratio(0,:) = p_rat
  cc(0,:)    = p_cc 

  ratio(1,:) = t_rat
  cc(1,:)    = t_cc 
;**********************************
; create plot
;**********************************
  res                 = True                     ; diagram mods desired
  res@tiMainString    = "Example"                ; title
  res@Colors          = (/"red","blue"/)         ; marker colors
  res@Markers         = (/14,9/)                 ; marker styles
  res@markerTxYOffset = 0.04                     ; offset btwn marker & label
  res@gsMarkerSizeF   = 0.01                     ; marker size   
  res@txFontHeightF   = 0.015                    ; text size 

  res@stnRad          = (/ 0.5, 1.5 /)     ; additional standard radii
  res@ccRays          = (/ 0.6, 0.9 /)     ; correlation rays
  res@ccRays_color    = "LightGray"        ; default is "black"

  res@centerDiffRMS   = True               ; RMS 'circles'
  res@centerDiffRMS_color = "LightGray"    ; default is "black"

  wks   = gsn_open_wks("png","taylor")     ; send graphics to PNG file 
  plot  = taylor_diagram(wks, ratio, cc, res)

end 
