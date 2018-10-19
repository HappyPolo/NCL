;*************************************************
; panel_35.ncl
;
; Concepts illustrated:
;   - Attaching three filled contour plots along Y axes
;   - Adding a common labelbar to attached plots
;   - Adding a common title to attached plots
;   - Generating dummy data using "generate_2d_array"
;   - Drawing a custom labelbar
;   - Drawing a custom title
;   - Retrieving the bounding box of a plot
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;********************************************************************
; This function draws a centered title above the given plot.
;********************************************************************
function main_title(wks,plot,title)
local txres, bb, txid, top
begin
;---Get bounding box that encloses plot, so we know where the top edge is.
  bb  = NhlGetBB(plot)
  top = bb(0)             ; top edge of plot

  txres               = True
  txres@txFontHeightF = 0.025
  txres@txFont        = "Helvetica-bold"
  txres@txJust        = "BottomCenter"
  txres@txPosXF       = 0.50         ; Centered
  txres@txPosYF       = top + 0.01   ; Add a little bit of a gap between top of plot 
                                     ; and bottom of title.

  txid = gsn_create_text(wks,title,txres)

  draw(txid)
  return(txid)
end

;********************************************************************
; This function creates and draws a labelbar based on a given 
; contour plot.
;********************************************************************
function labelbar(wks,plot)
local colors, levels, labels, nboxes, bb, bot
begin
;---Get bounding box that encloses plot, so we know where the bottom edge is.
  bb  = NhlGetBB(plot)
  bot = bb(1)             ; bottom edge of plot

;---Retrieve the contour levels and their associated colors.
  getvalues plot
    "cnLevels"     : levels
    "cnFillColors" : colors
  end getvalues

  nboxes = dimsizes(colors)

  labels                   = ""+levels    ; labels for the labelbar

;---Set some labelbar resources.
  lbres                    = True
  lbres@vpXF               = 0.15         ; Position labelbar at         
  lbres@vpYF               = bot          ; bottom edge of plot
  lbres@vpWidthF           = 0.70
  lbres@vpHeightF          = 0.10

  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbOrientation      = "Horizontal"     ; Default is vertical.
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True             ; Fill them all solid.
  lbres@lbLabelFontHeightF = 0.013            ; Label font height
  lbres@lbLabelAlignment   = "InteriorEdges"

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)

  draw(lbid)     ; Draw labelbar

  return(lbid)   ; Return it so we can maximize later if desired.
end

;********************************************************************
; Main code.
;********************************************************************

begin
;---Generate 3 dummy data sets. 
  nx     = 100
  ny     = 100
  nplots = 3

  data        = new((/nplots,ny,nx/),float)
  data(0,:,:) = generate_2d_array(10, 10, -19.,16., 0, (/ny,nx/))
  data(1,:,:) = generate_2d_array(10, 10, -28.,15., 1, (/ny,nx/))
  data(2,:,:) = generate_2d_array(10, 10, -25.,18., 2, (/ny,nx/))

;---Calculate some "nice" contour intervals for all plots.
  mnmxlvl = nice_mnmxintvl(min(data),max(data),16,False)

;---Start the graphics.
  contour = new(nplots,graphic)  ; Array to hold plots

  wks = gsn_open_wks("png","panel")  ; send graphics to PNG file

  res                           = True

  res@gsnFrame                  = False
  res@gsnDraw                   = False

;
; Force all plots to have same contour levels. This is important
; so we can use one labelbar to represent all three plots.
;
  res@cnLevelSelectionMode      = "ManualLevels"
  res@cnMinLevelValF            = mnmxlvl(0)
  res@cnMaxLevelValF            = mnmxlvl(1)
  res@cnLevelSpacingF           = mnmxlvl(2)

  res@cnLineLabelsOn            = False  ; Turn off contour line labels
  res@cnFillOn                  = True   ; Turn on contour fill
  res@cnFillPalette             = "BlueYellowRed"

  res@cnInfoLabelOn             = False  ; Turn off info label
  res@lbLabelBarOn              = False  ; Turn off individual labelbars

  do i=0,nplots-1
    contour(i) = gsn_csm_contour(wks,data(i,:,:),res)
  end do
;
; Attach three plots along the Y axes (the default).
;
; Make sure the variable returned by gsn_attach_plots
; is unique every time.
;
  res1             = True
  res2             = True
  res1@gsnMaximize = True

  anno1 = gsn_attach_plots(contour(0),contour(1:2),res1,res2)

;---Draw the three attached plots
  draw(contour(0))

;---Create and draw a labelbar and main title.
  lb = labelbar(wks,contour(0))
  tx = main_title(wks,contour(0),"Three dummy plots attached along Y axes")

  frame(wks)                     ; Advance frame

end

