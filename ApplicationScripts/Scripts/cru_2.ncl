;*****************************************************
; cru_2.ncl
;
; Concepts illustrated:
;   - Plotting CRU (Climate Research Unit) data
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Spanning the full color map for contour fill
;   - Turning off contour lines
;   - Turning off contour line labels
;   - Converting "short" data to "float"
;   - Paneling two plots vertically on a page
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
;*****************************************************
begin
;*****************************************************
; Read Absolute temperatures for the base period 1961-90
; data are stored as type "short" ... convert to float
;***************************************************
  f    = addfile("absolute.nc","r")
  T    = short2flt( f->tem )                          ; contributed.ncl
  T@long_name = "Temperature"          ; change value original too long
;***************************************
; create individual plots
;***************************************  
  wks = gsn_open_wks("png","cru")               ; send graphics to PNG file
  plot = new(2, graphic)                        ; create graphical array

  res                      = True               ; plot mods desired

  res@cnFillOn             = True               ; color contours
  res@cnFillPalette        = "gui_default"      ; set color map
  res@cnLinesOn            = False              ; default is True
  res@cnLineLabelsOn       = False              ; default is True

  res@gsnDraw              = False              ; don't draw yet
  res@gsnFrame             = False              ; don't advance frame yet

  res@gsnCenterString      = "February"
  plot(0)  = gsn_csm_contour_map(wks,T(1,:,:),res)
  res@gsnCenterString      = "August"
  plot(1)  = gsn_csm_contour_map(wks,T(7,:,:),res)

; create panel plot
  gsn_panel(wks,plot,(/2,1/),False)
end
