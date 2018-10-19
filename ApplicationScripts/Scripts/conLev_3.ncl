;----------------------------------------------------------------------
; conLev_3.ncl
;
; Concepts illustrated:
;   - Making the labelbar be vertical
;   - Adding text to a plot
;   - Adding units attributes to lat/lon arrays
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
; This script explains how NCL bins color contours. A similar version
; of this graphic is used in the NCL workshop graphics lecture.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Note that "t" on this file has no attributes like "long_name"
; or "units". Add units attributes to the coordinate arrays and
; see what happens to plot.
;
  tf = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/Tstorm.cdf","r")
  T           = tf->t(0,:,:)                   ; Read in temperature data.
  T&lon@units = "degrees_east"
  T&lat@units = "degrees_north"

  wks = gsn_open_wks("png","conLev") ; send graphics to PNG file

  res                          = True

  res@gsnMaximize              = True
  res@gsnDraw                  = False
  res@gsnFrame                 = False

  res@cnFillOn                 = True
  res@cnFillPalette            = "rainbow"

  res@tmYROn                   = False

  res@tiMainString             = "Explanation of NCL contour levels"

  res@lbOrientation            = "Vertical"
  res@pmLabelBarOrthogonalPosF = -0.02

  plot = gsn_csm_contour(wks,T,res)

;---Retrieve some information on the levels and min/max X/Y values
  getvalues plot
    "cnLevels" : levels
    "trYMinF"  : ymin
    "trYMaxF"  : ymax
    "trXMinF"  : xmin
    "trXMaxF"  : xmax
  end getvalues

;---Calculate location for text strings to add.
  nlevels = dimsizes(levels)
  yrng    = ymax-ymin
  ymrg    = yrng*0.012   ; a slight margin
  yloc    = fspan(ymin+ymrg,ymax-ymrg,nlevels+2)
  ydlt    = (yloc(1)-yloc(0))/2.
  yloc    = yloc+ydlt
  xloc    = xmax

;---Text resources
  txres                       = True
  txres@txJust                = "CenterRight"
  txres@txFontHeightF         = 0.01
  txres@txBackgroundFillColor = "papayawhip"

  txid = new(nlevels+1,graphic)

;---Loop through each level and add a string with an explanation
  do i=0,nlevels
    if(i.eq.0) then
      str = "T < " + levels(i)
    else if(i.eq.nlevels) then
      str = "T >= " + levels(i-1)
    else
      str = levels(i-1) + " <= T < " + levels(i)
    end if
    end if
    txid(i) = gsn_add_text(wks,plot,str,xloc,yloc(i),txres)
  end do

;---Drawing the plot will draw all the attached strings.
  draw(plot)
  frame(wks)

end
