;*************************************************
; scatter_5.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot with markers of different colors
;   - Generating dummy data using "random_chi"
;   - Drawing a legend outside an XY plot
;   - Changing the markers in an XY plot
;   - Changing the marker color in an XY plot
;   - Changing the marker size in an XY plot
;   - Manually creating a legend using markers and text
;   - Adding text to a plot
;   - Using "nice_mnmxintvl" to select a nice span of values through the data
;   - Creating a color map using named colors
;   - Moving a legend closer to a plot
;   - Customizing the labels in a legend
;   - Changing the orientation of a legend
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate random data with an average of 10 and a stddev of 3.
  npts   = 300
  data1d = random_normal(10.,3.,npts)

;---Create roughly ten equally spaced levels through the data.
  mnmxint = nice_mnmxintvl(min(data1d),max(data1d),10,True)
  nlevels = toint(((mnmxint(1)-mnmxint(0))/mnmxint(2))) + 1
  levels  = fspan(mnmxint(0),mnmxint(1),nlevels)

  print("min/max data = " + min(data1d) + "/" + max(data1d))
  print("# of groups  = " + (nlevels-1))
  print("levels start at = " + levels(0) + ", end at " + levels(nlevels-1) + \
        ", with a spacing of " + mnmxint(2))

;---Create new 2D array to hold groupings of values
  data2d = new((/nlevels-1,npts/),typeof(data1d))

;---Group the values and put in 2D array.
  labels = new(nlevels-1,string)
  do i=0,nlevels-2
    ii = ind(data1d.ge.levels(i).and.data1d.lt.levels(i+1))
    data2d(i,ii) = data1d(ii)
    labels(i) = levels(i) + ":" + levels(i+1)
    delete(ii)
  end do

;----------------------------------------------------------------------
; Graphics section
;----------------------------------------------------------------------

;---Define the colors for the markers. white/black = background/foreground
  colors = (/"white","black","darkgoldenrod","darkgreen","coral4", \ 
             "cyan3","firebrick1","darkslateblue","limegreen",     \
             "lightgoldenrod","darkseagreen1","lightsteelblue1"/)

  wks  = gsn_open_wks("png","scatter")            ; send graphics to PNG file
  gsn_define_colormap(wks,colors)

;---Create a scatter plot
  res                    = True                   ; plot mods desired
  res@gsnMaximize        = True
  res@tiMainString       = "Scatter plot with grouped markers"

;---Set some legend resurces
  res@pmLegendDisplayMode    = "Always"         ; Turn on the legend
  res@lgOrientation          = "horizontal"     ; Default is vertical
  res@pmLegendWidthF         = 0.75             ; Make it wider
  res@pmLegendOrthogonalPosF = -0.1             ; Move it up slightly
  res@lgPerimOn              = False            ; Turn off the perimeter box
  res@xyExplicitLabels       = labels           ; Set the legend labels

;---Set some marker resources
  res@xyMarkLineMode     = "Markers"
  res@xyMarkerThicknessF = 2.5
  res@xyMarkerColors     = colors(2:)   ; It's okay to list more than you need here
;
; Set the marker indexes. There are 17 predefined ones at:
;
;   http://www.ncl.ucar.edu/Document/Graphics/Images/markers.png
;
; or you can define your own with NhNewMarker:
;   http://www.ncl.ucar.edu/Document/Functions/Built-in/NhlNewMarker.shtml
;
  res@xyMarkers          = ispan(2,16,1)  ; Again, you can list more than you need.


  plot  = gsn_csm_y (wks,data2d,res)

end
