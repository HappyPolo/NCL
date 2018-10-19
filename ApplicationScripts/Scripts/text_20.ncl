;----------------------------------------------------------------------
; text_20.ncl
;
; Concepts illustrated:
;   - Drawing text on the frame using NDC coordinates
;   - Using drawNDCGrid to draw a nicely labeled NDC grid
;   - Using viewport resources to specify the location of text strings
;   - Using bounding box values to specify the location of text strings
;   - Rotating text 90 degrees
;   - Changing the color of text strings
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
begin
;---Generate some random data
  nx     = 20
  x      = ispan(1,nx,1)
  y      = new((/2,nx/),float)
  y(0,:) = random_uniform(1.,10.,nx)

;
; Calculate a set of coefficients for a least-squares 
; polynomial fit. All weights are set to 1.
;
  c      = lspoly(x, y(0,:), 1, 4)
  y(1,:) = c(0) + c(1)*y(0,:) + c(2)*(y(0,:)^2) + c(3)*(y(0,:)^3)

;---Start the graphics.
  wks = gsn_open_wks ("png","text")

  res                   = True  
  res@gsnFrame          = False         ; Suspend frame advanced until after
                                        ; we draw an NDC grid (see below).

  res@tiMainString      = "least-squares polynomial fit (lspoly)"
  res@xyMarkLineModes   = (/"Markers","Lines"/)

  res@xyMarker          =  16                  ; Change type, size, and
  res@xyMarkerSizeF     = 0.008                ; color of marker
  res@xyLineThicknessF  = 3.0                  ; and color of line

  plot = gsn_csm_xy (wks, x, y, res)

;----------------------------------------------------------------------
; In order to place text around the outside of a plot, you may need to
; retrieve both the viewport of the plot itself, and the bounding box.  
; 
; The viewport is the location and size of the plot, not including the 
; titles or tickmarks outside the plot.
; 
; The bounding box is the location and size of a box that exactly
; encloses all plot elements, including titles, tickmarks, tickmark 
; labels, etc.
;----------------------------------------------------------------------

;---Get bounding box of plot
  bb  = NhlGetBB(plot)   ; top, bottom, left, right
  top = bb(0)
  bot = bb(1)
  lft = bb(2)
  rgt = bb(3)

;---Get viewport of plot
  getvalues plot
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

  rgt_edge_plot = vpx+vpw

;---Draw an NDC grid so we can see where to put text outside plot
  drawNDCGrid(wks)
  frame(wks)

;---Draw plot again
  draw(plot)

;---Set text options and draw text using NDC coordinates
  txres               = True
  txres@txFontHeightF = 0.02

  txres@txFontColor   = "DarkOrchid4"
  txres@txJust        = "CenterLeft"
  gsn_text_ndc(wks,"Text close to bottom left corner",0.01,0.05,txres) 

  txres@txFontColor   = "DarkGreen"
  txres@txJust        = "CenterRight"
  gsn_text_ndc(wks,"Text close to bottom right corner",0.99,0.05,txres) 

  txres@txFontColor   = "Brown"
  txres@txJust        = "BottomRight"
  gsn_text_ndc(wks,"Text flush right with right edge of plot",rgt_edge_plot,top+0.01,txres)

  txres@txFontColor   = "DarkOrange1"
  txres@txJust        = "TopLeft"
  gsn_text_ndc(wks,"Text at very top left corner",0.0,1.0,txres)
 
  txres@txJust        = "TopCenter"
  txres@txFontColor   = "coral4"
  gsn_text_ndc(wks,"Text centered below bottom of plot",0.5,bot-0.02,txres)

  txres@txAngleF      = 90.     ; rotate 90 degrees
  txres@txJust        = "TopCenter"
  txres@txFontColor   = "SkyBlue4"
  gsn_text_ndc(wks,"Text centered outside right edge of plot",rgt+0.01,0.5,txres)

  txres@txAngleF      = -90.     ; rotate 90 degrees
  txres@txJust        = "TopLeft"
  txres@txFontColor   = "DeepPink1"
  gsn_text_ndc(wks,"Text flush with top left edge of plot",lft-0.01,vpy,txres)

;---Now advance frame
  frame(wks)
end
