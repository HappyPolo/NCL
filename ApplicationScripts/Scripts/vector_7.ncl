;----------------------------------------------------------------------
; vector_7.ncl
;
; Concepts illustrated:
;   - Drawing a black-and-white vector plot
;   - Drawing polymarkers at the coordinate positions of vectors
;   - Changing the position of the vector arrow relative to data location
;   - Attaching polymarkers to a vector plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Generate dummy vector data arrays
  M=30
  N=25
  PI=3.14159

  xN = ispan(0,N-1,1)
  xM = ispan(0,M-1,1)
  x1 = 10.0 * cos((2.0 * PI / N) * xN)
  x2 = 10.0 * cos((2.0 * PI / M) * xM)
  U  = conform_dims((/N,M/),x1,0)
  V  = conform_dims((/N,M/),x2,1)

;---These are for markers later
  x  = conform_dims((/N,M/),xM,1)
  y  = conform_dims((/N,M/),xN,0)

;---Start the graphics
  wks = gsn_open_wks("png" ,"vector")  ; send graphics to PNG file

  res                       = True

  res@gsnMaximize           = True
  res@gsnDraw               = False
  res@gsnFrame              = False

  res@vcRefMagnitudeF       = 20.

;---Marker resources for later
  mkres                     = True
  mkres@gsMarkerIndex       = 16       ; Filled dot
  mkres@gsMarkerColor       = "red"
  mkres@gsMarkerSizeF       = 0.003

;---The default position for vectors is "ArrowCenter"
  vector_positions = (/"ArrowCenter","ArrowTail","ArrowHead"/)

;
; Loop through each vector position and create a plot that
; uses this setting. Also add polymarkers at the vector
; base locations.
;
  do i=0,dimsizes(vector_positions)-1
    res@vcPositionMode = vector_positions(i)
    res@tiMainString   = "'vcPositionMode' = " + res@vcPositionMode

    plot = gsn_csm_vector(wks,U, V, res) 

    plot@mkid = gsn_add_polymarker(wks,plot,x,y,mkres)

;---Drawing the plot draws the vectors and the markers
    draw(plot)
    frame(wks)
  end do
end
