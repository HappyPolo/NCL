;----------------------------------------------------------------------
; minmax_4.ncl
;
; Concepts illustrated:
;   - Using the WhiteBlue color map
;   - Replacing colors in the existing color map with named colors
;   - Changing the contour level spacing
;   - Attaching polymarkers to a contour plot
;   - Calculating the local minima/maxima of your data
;   - Adding text strings at local minima/maxima locations
;   - Drawing a custom legend outside of a map plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
;---Open file and read in Sea Surface Temperature Anomalies
  a   = addfile("sst8292a.nc","r")
  sst = a->SSTA

;---Start the graphics
  wks = gsn_open_wks("png","minmax")          ; send graphics to PNG file

  res                      = True

  res@gsnMaximize          = True               ; maximize plot in frame
  res@gsnDraw              = False
  res@gsnFrame             = False

  res@cnFillOn             = True               ; turn on contour fill
  res@cnFillPalette        = "WhiteBlue"        ; set color map
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour labels
  res@cnLevelSpacingF      = 0.2

  res@tiMainString         = "January 1982"
  res@mpFillDrawOrder      = "PostDraw"         ; Draw map fill last

;---Create plot
  nt = 0
  plot = gsn_csm_contour_map(wks,sst(nt,:,:),res)

;
; Called local_min and local_max to get lat/lon locations of local 
; minima and maxima. The lat/lon locations will be returned as
; index values in the X and Y dimensions, "xi" and "yi". 
;
  iimin = local_min(sst(nt,:,:),False,0.)
  iimax = local_max(sst(nt,:,:),False,0.)

  mkres               = True
  mkres@gsMarkerIndex = 16        ; filled dot
  mkres@gsMarkerSizeF =  8.       ; make dot larger

  mkres@gsMarkerColor = "green"
  dumlow = gsn_add_polymarker(wks,plot,sst&lon(iimin@xi),sst&lat(iimin@yi),mkres)

  mkres@gsMarkerColor = "red"
  dumhgh = gsn_add_polymarker(wks,plot,sst&lon(iimax@xi),sst&lat(iimax@yi),mkres)

  draw(plot)   ; Drawing the plot draws the attached markers too

;---Draw a legend at the bottom
  txres               = True
  txres@txJust        = "CenterLeft"
  txres@txFontHeightF = 0.02
  mkres@gsMarkerSizeF = 10.       ; make dot larger

  xpos = 0.15
  ypos = 0.15

  mkres@gsMarkerColor = "green"
  gsn_polymarker_ndc(wks,xpos,ypos,mkres)
  gsn_text_ndc(wks,"  Locations of local minima",xpos,ypos,txres)

  xpos = 0.55
  ypos = 0.15
  mkres@gsMarkerColor = "red"
  gsn_polymarker_ndc(wks,xpos,ypos,mkres)
  gsn_text_ndc(wks,"  Locations of local maxima",xpos,ypos,txres)

  frame(wks)
end
