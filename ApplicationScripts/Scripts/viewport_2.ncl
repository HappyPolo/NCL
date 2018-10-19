;*************************************************
; viewport_2.ncl
;
; Concepts illustrated:
;   - Drawing a simple filled contour plot
;   - Drawing a box around a contour plot viewport
;   - Drawing the bounding box
;   - Changing the color and thickness of polylines
;   - Drawing polylines, polymarkers, and text in NDC space
;   - Using "getvalues" to retrieve resource values
;   - Generating dummy data
;   - Subsetting a color map
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


;********************************************************************
; Draw a box around the viewport of the given object..
;********************************************************************
procedure draw_vp_box(wks,plot)
local vpx, vpy, vpw, vph, xbox, ybox, lnres, mkres, txres
begin

; Retrieve the viewport values of the drawable object.
  getvalues plot
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

; Make a box with the viewport values.
  xbox = (/vpx,vpx+vpw,vpx+vpw,vpx,vpx/)
  ybox = (/vpy,vpy,vpy-vph,vpy-vph,vpy/)

; Set up some marker resources.
  mkres                  = True
  mkres@gsMarkerIndex    = 16     ; filled dot
  mkres@gsMarkerSizeF    = 0.02   ; larger than default
  mkres@gsMarkerColor    = "ForestGreen"

; Draw a single marker at the vpXF/vpYF location.
  gsn_polymarker_ndc(wks,vpx,vpy,mkres)

; Set up some line resources.
  lnres                  = True
  lnres@gsLineColor      = "NavyBlue"  ; line color
  lnres@gsLineThicknessF = 3.5         ; 3.5 times as thick

; Draw a box around the viewport.
  gsn_polyline_ndc(wks,xbox,ybox,lnres)

; Set up some text resources.
  txres                       = True  
  txres@txJust                = "CenterLeft"
  txres@txFontHeightF         = 0.015
  txres@txFontColor           = "ForestGreen"
  txres@txBackgroundFillColor = "white"

; Draw a text string labeling the marker
  gsn_text_ndc(wks,"(vpXF,vpYF)",vpx+0.03,vpy,txres)

; Draw text strings labeling the viewport box.
  txres@txFontColor           = "black"
  txres@txJust                = "CenterLeft"

  gsn_text_ndc(wks,"viewport",vpx+vpw/2.,vpy-vph,txres)
  gsn_text_ndc(wks,"viewport",vpx+vpw/2.,vpy,txres)

  txres@txAngleF = 90.
  gsn_text_ndc(wks,"viewport",vpx,vpy-vph/2.,txres)
  gsn_text_ndc(wks,"viewport",vpx+vpw,vpy-vph/2.,txres)

end

;********************************************************************
; Draw a box around the bounding box of the given object..
;********************************************************************
procedure draw_bb_box(wks,plot)
local bb, top, bot, lft, rgt, xbox, ybox, lnres
begin
; Retrieve the bounding box of the given object.
  bb  = NhlGetBB(plot)
  top = bb(0)
  bot = bb(1)
  lft = bb(2)
  rgt = bb(3)

; Make a box with the bounding box values.
  xbox = (/rgt,lft,lft,rgt,rgt/)
  ybox = (/top,top,bot,bot,top/)

; Set up some line resources.
  lnres                   = True
  lnres@gsLineColor       = "Brown"
  lnres@gsLineThicknessF  = 2.5

; Set up some text resources.
  txres                       = True
  txres@txFontHeightF         = 0.015
  txres@txBackgroundFillColor = "white"
  txres@txJust                = "CenterLeft"

; Draw a box showing the bounding box.
  gsn_polyline_ndc(wks,xbox,ybox,lnres)

; Draw text strings labeling the bounding box.

  gsn_text_ndc(wks,"bounding box",lft+0.05,bot,txres)
  txres@txJust                = "CenterRight"
  gsn_text_ndc(wks,"bounding box",rgt-0.05,top,txres)

  txres@txAngleF              = 90.
  txres@txJust                = "CenterRight"
  gsn_text_ndc(wks,"bounding box",lft,top-0.05,txres)

  txres@txJust                = "CenterLeft"
  gsn_text_ndc(wks,"bounding box",rgt,bot+0.05,txres)

end

;********************************************************************
; Main code
;********************************************************************
begin
  wks = gsn_open_wks("png","viewport")  ; send graphics to PNG file

;---Read colormap so we can subset it later
  cmap    = read_colormap_file("nrl_sirkes")
  ncolors = dimsizes(cmap(:,0))  

; Generate some dummy data.

  data = generate_2d_array(10, 10, -19.,16., 0, (/100,100/))

; Set up resources for a contour plot.

  cnres                   = True

  cnres@gsnMaximize       = True      ; Maximize plot in frame
  cnres@gsnDraw           = False     ; Don't draw plot
  cnres@gsnFrame          = False     ; Don't advance the frame

  cnres@cnFillOn          = True        ; Turn on contour fill
  cnres@cnFillPalette     = cmap(0:ncolors-4,:)   ; skip last 3 colors
  cnres@lbOrientation     = "Vertical"  ; Default is horizontal

  cnres@tiMainString      = "This is a title"
  cnres@tiXAxisString     = "X axis"
  cnres@tiYAxisString     = "Y axis"
  cnres@gsnLeftString     = "left string"
  cnres@gsnRightString    = "right string"

  contourplot = gsn_csm_contour(wks,data,cnres)

; Draw plot without any boxes first.

  draw(contourplot)

; Advance frame.
  frame(wks)

; Draw plot and add viewport and bounding boxes.
  draw(contourplot)
  draw_bb_box(wks,contourplot)
  draw_vp_box(wks,contourplot)

; Advance frame.
  frame(wks)
end
