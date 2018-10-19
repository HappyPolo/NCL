;================================================;
;  popscal_2.ncl
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ================================================;
begin
  f         = addfile("TEMP.nc","r")

  t         = f->TEMP              ; (time, z_t, nlat, nlon)

  t@lon2d   = f->TLONG             ; associate 2D arrays containing
  t@lat2d   = f->TLAT              ; coordinates with variable

;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("png","popscal")          ; send graphics to PNG file

  res                     = True                ; plot mods desired
  res@gsnDraw             = False               ; do not draw
  res@gsnAddCyclic        = True                ; add cyclic point
  res@gsnFrame            = False               ; do not advance the frame
  res@cnLineLabelsOn      = False               ; turn off line labels
  res@cnFillDotSizeF      = 0.0025              ; increase stippling visibility
  res@tiMainString        = "Shade values < 5"  ; add title

  plot = gsn_csm_contour_map(wks,t(0,0,:,:),res)  ; time=0, z_t=0  

;=================================================
; Shade areas less than the 5. contour level. The gsn_contour_shade
; function will shade contours greater than and/or less than
; contour levels given as numeric arguments to the function.
;=================================================  
  opt  = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeLow      = 17

  plot = gsn_contour_shade(plot, 5.5, 20, opt)   ; shade areas < 5. 20 used as a dummy value.
  draw (plot)                                    ; draw the plot
  frame(wks)                                     ; advance the frame


      
  end
