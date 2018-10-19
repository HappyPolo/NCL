;---------------------------------------------------------------
; unique_2.ncl
;
; Concepts illustrated:
;   - Using vectors to draw a stick plot
;   - Generating dummy data using "random_uniform"
;   - Drawing vectors with no arrow heads
;---------------------------------------------------------------
;
; The purpose of this program is to plot multiple stick plots on one plot
; and to have the vectors be in their own reference frame.  Setting
; the resource "vcMapDirection = False" is the key to plotting the sticks
; in their own reference frame.      
;
; Wind, currents, and wind stress are a few examples of parameters 
; that might be plotted in this style.
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Create some random vector data.  
;
  low = -10
  high = 10
  npts = 101

  Uoc  = random_uniform(low,high,npts)
  Uoc2 = random_uniform(low,high,npts)
  Voc  = random_uniform(low,high,npts)
  Voc2 = random_uniform(low,high,npts)

;
; Create vector arrays with time series data spaced within it.
;
  row = 4
  col = dimsizes(Uoc)
  U   = new((/row,col/),float)
  V   = U
  avgwind  = 1
  fullwind = 2
  U(fullwind,:) = Uoc
  V(fullwind,:) = Voc    
  U(avgwind,:)  = Uoc2
  V(avgwind,:)  = Voc2

;
; Make stick plots.
;
  wks = gsn_open_wks("png","unique")    ; send graphics to PNG file

  res = True
;   
; Viewport width and height.
;
  res@vpXF     = 0.04
  res@vpWidthF = 0.94
  res@vpHeightF = (2./3.) * res@vpWidthF
;    
; Title/Axis Labels
;
  res@tiXAxisString      = "Sample Number"
  res@tiMainString       = "Stick Plot"
  res@tiXAxisFontHeightF = 0.015
;    
; Vector resources
;
  res@vcRefMagnitudeF         = 10
  res@vcRefLengthF            = .05
  res@vcMinFracLengthF        = 0
  res@vcGlyphStyle            = "LineArrow"
  res@vcMapDirection          = False
  res@vcLineArrowThicknessF   = 2.5
  res@vcLineArrowHeadMaxSizeF = 0
  res@vcLineArrowHeadMinSizeF = 0
  res@vcPositionMode          = "ArrowTail"
  res@vcRefAnnoOn             = True  		; Turns on reference vector box (default = True)
  res@vcRefAnnoOrthogonalPosF = -0.1665		; Moves reference vector box inside the plot

;
; Tick Marks/Labels
;
  res@tmYLMode             = "Explicit"
  res@tmYLValues           = (/0,1,2,3/)
  res@tmYLLabels           = (/"","Data 2","Data 1",""/)
  res@tmYLLabelAngleF      = 90.
  res@tmYLLabelJust        = "CenterCenter"
  res@tmYLLabelFontHeightF = 0.015
    
  res@tmXTOn               = False
  res@tmXBMinorOn          = False
  res@tmXBMajorLengthF     = 0.01
  res@tmXBLabelFontHeightF = 0.015
    
  vector = gsn_vector(wks,U,V,res)

end
