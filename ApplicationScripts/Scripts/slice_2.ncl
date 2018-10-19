;================================================;
;  slice_2.ncl
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
;=================================================;
; open file and read in data
;=================================================;
  f    = addfile("cone.nc","r")
  u  = f->u(:,6,:)

; In this file, the coordinate variables of the data are listed as 
; lat and long, but they are really just index points, which makes this
; data suitable for plotting without a map.

;=================================================;
; PLOT 
;=================================================;
  wks  = gsn_open_wks("png","slice")      ; send graphics to PNG file

  res                     = True          ; plot mods desired
  res@trYReverse          = True          ; reverses y-axis

  res@tiYAxisString       = "Level"       ; y-axis title
  res@tiXAxisString       = "X-pts"       ; y-axis title

  plot = gsn_contour(wks,u,res)           ; contour the variable


  end
