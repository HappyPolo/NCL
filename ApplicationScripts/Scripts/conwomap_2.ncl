;================================================;
;  conwomap_2.ncl
;
; Concepts illustrated:
;   - Drawing a simple filled contour plot
;   - Selecting a different color map
;   - Changing the size/shape of a contour plot using viewport resources
;
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
  u  = f->u(4,:,:)                
;=================================================;
; PLOT 2
;=================================================;
  wks  = gsn_open_wks("png","conwomap")   ; send graphics to PNG file

  res                     = True          ; plot mods desired

  res@cnFillOn            = True          ; turn on color
  res@cnFillPalette       = "gui_default" ; set color map
 
  res@vpWidthF            = 0.5           ; change aspect ratio of plot
  res@vpHeightF           = 0.3

  res@gsnMaximize         = True          ; maximize plot size

  plot = gsn_csm_contour(wks,u,res)       ; contour the variable

; In this file, the coordinate variables of the data are listed as 
; lat and long, but they are really just index points, which makes this
; data suitable for plotting without a map.
  end
