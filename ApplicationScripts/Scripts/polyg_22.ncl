;----------------------------------------------------------------------
; polyg_22.ncl
;
; Concepts illustrated:
;   - Comparing various hollow circle markers
;   - Creating your own markers using NhlNewMarker
;   - Using gsn_csm_blank_plot to create a blank plot for drawing markers
;----------------------------------------------------------------------
; This script shows a way to draw smooth hollow circles when you need
; to make them large. The default hollow circle (index 4 in the marker
; table) starts to look blocky if you blow it up. You can instead use
; one of the hollow circles available in NCL's various font tables for
; smoother results. This script compares various hollow circles from
; these tables against marker index #4.
; 
; http://www.ncl.ucar.edu/Document/Graphics/font_tables.shtml
;----------------------------------------------------------------------
; See also polyg_21.ncl which shows how to generate the circles 
; yourself.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Hollow markers to compare
  table_num = (/19, 19, 37, 19/)     ; Table 19 has several hollow circles
  letter    = (/"Y","y","R","z"/)

  nmarkers = dimsizes(table_num)+1   ; add one for the default hollow marker
  nsizes   = 8    ; # of sizes to draw for each marker
  
;--Define marker ids, positions, sizes and labels
  xdist     = 1./(nmarkers)
  ydist     = 1./(nsizes+1)
  xpos      = ispan(1,nmarkers,1)*xdist
  ypos      = ispan(1,nsizes,1)*ydist
  sizes     = ispan(1,nsizes,1)*0.01
  ylabels   = "" + sizes
  xlabels   = new(nmarkers,string)
  marker_id = new(nmarkers,integer)

;--Need to create a workstation before we can define markers
  wks = gsn_open_wks("png","polyg")

;---First marker is a predefined one in NCL's marker table
  marker_id(0) = 4   ; hollow circle in predefined marker table
  xlabels(0)   = "default hollow~C~      circle"

;---Get indexes for rest of markers
  marker_id(1:) = NhlNewMarker(wks,letter,table_num,0.,0.,1.,1.,0.)
  xlabels(1:)   = "table #" + table_num + "~C~ letter " + letter

;---Define resources for blank plot
  res             = True
  res@gsnMaximize = True
  res@gsnFrame    = False
  res@gsnScale    = True  ; make sure labels/titles on X and Y axis are the same size

;---Shape of plot
  res@vpWidthF    = 0.8
  res@vpHeightF   = 0.4

;---X and Y axis limits
  res@trYMaxF     = 1.2
  res@trXMinF     = min(xpos)-0.1
  res@trXMaxF     = max(xpos)+0.15

;---Tickmarks
  res@tmXBMode    = "Explicit"
  res@tmXTOn      = False
  res@tmYROn      = False
  res@tmXBValues  = xpos
  res@tmXBLabels  = xlabels
  res@tmYLMode    = "Explicit"
  res@tmYLValues  = ypos
  res@tmYLLabels  = ylabels
  res@tmXBLabelFontHeightF = 0.01

;---Titles
  res@tiMainString  = "comparing hollow circles"
  res@tiYAxisString = "marker sizes"
  res@tiXAxisString = "marker indexes"
  res@tiXAxisFontHeightF = 0.015
  res@tiYAxisFontHeightF = 0.015

;---Define resources for markers to be drawn on blank plot
  mkres                    = True
  mkres@gsMarkerColor      = "black"
  mkres@gsMarkerThicknessF = 2.0

;---For each marker type and size, draw a marker on the blank plot
  plot = gsn_csm_blank_plot(wks,res)
  do nc=0,nmarkers-1
    mkres@gsMarkerIndex = marker_id(nc)
    do ns=0,nsizes-1
      mkres@gsMarkerSizeF = sizes(ns)
      gsn_polymarker(wks,plot,xpos(nc),ypos(ns),mkres)
    end do
  end do
  frame(wks)
end
