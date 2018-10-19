;*****************************************************
; xy_31.ncl
;
; Concepts illustrated:
;   - Changing the line dash pattern in an XY plot
;   - Creating your own line dash pattern for an XY plot
;   - Changing the line thickness in an XY plot
;   - Drawing a legend inside an XY plot
;   - Customizing the labels in a legend
;   - Changing the width and height of a legend
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Define the number of points in each curve.
  NPTS  = 500
  PI100 = 0.031415926535898
  theta  = PI100*ispan(0,NPTS-1,1)

;---Create 4 dummy curves.
  NCURVES = 4
  y       = new((/NCURVES,NPTS/),float)
  do i=0,NCURVES-1
    y(i,:) = sin((i+1)*sqrt(fabs(theta)))
  end do

;---Space the curves out a little.
  y(2,:) = 2 + y(2,:)
  y(3,:) = 2 + y(3,:)

  wks = gsn_open_wks("png","xy")   ; send graphics to PNG file

  res                   = True     ; Plot options desired
  res@gsnMaximize       = True     ; Maximize plot in frame
  res@xyLineThicknessF  = 7        ; Make lines really thick
  res@trYMinF           = -2       ; Leave a margin for legend

;---Make legend smaller and move into plot
  res@pmLegendOrthogonalPosF = -0.33
  res@pmLegendParallelPosF   = 0.1
  res@pmLegendDisplayMode    = "Always"
  res@pmLegendWidthF         = 0.1
  res@pmLegendHeightF        = 0.1

;---Change the legend line labels
  res@xyExplicitLegendLabels = "y" + ispan(1,NCURVES,1)

  res@tiMainString = "Using predefined dash patterns"
  xy = gsn_csm_y(wks,y,res)

;
; Create some patterns with more spaces between the lines, so that
; when thickened for publication purposes, you can still see that
; a line is dashed. The $ is pen down (line), and the _ is pen up
; (space). 
;
 patterns = (/ "$$$$______$$______$$$$______$$_____$$$$______", \
               "$___$$___$___$$___$___$$___$___$$___$", \
               "$$____$$____$$____$$____$$____$$____$$", \
               "$___$___$___$___$___"/)

  res@tiMainString   = "Creating your own dash patterns"
  res@xyDashPatterns = NhlNewDashPattern(wks,patterns)
  xy = gsn_csm_y(wks,y,res)

end
