;*************************************************
; histo_10.ncl
;
; Concepts illustrated:
;   - Overlaying multiple histograms for comparison using "overlay"
;   - Generating dummy data using "rand"
;   - Turning off color fill in a histogram
;   - Outlining bars in a histogram
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;************************************************
begin
;************************************************
; Generate some random data.
;************************************************
  x = new(1000,integer)
  y = new(1000,integer)
  z = new(1000,integer)
  do i=0,dimsizes(x)-1
    x(i) = rand()
    y(i) = rand()
    z(i) = rand()
  end do
  x = x/320
  y = y/320
  z = z/320
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","histo")             ; send graphics to PNG file

  res             = True                        ; plot mods desired
  res@gsnDraw     = False                       ; don't draw yet
  res@gsnFrame    = False                       ; don't advance frame yet

  res@gsFillColor = (/"transparent"/)           ; color bars transparent
  res@gsEdgeColor = "black"                     ; color of bar edges
  plot1 = gsn_histogram(wks,x,res)              ; create histogram 

  res@gsEdgeColor = "red"                       ; change color of edge
  plot2 = gsn_histogram(wks,y,res)            
  overlay(plot1,plot2)                          ; overlay the two histos
; note that plot1 is the result of this overlay and is carried on to the
; next overlay

  res@gsEdgeColor = "blue"                      ; change color again
  res@tiMainString = "x=black,y=red,z=blue"     ; add title
  plot3 = gsn_histogram(wks,z,res)            
  overlay(plot1,plot3)                          ; overlay result of first
                                                ; overlay with 3rd plot
  draw(plot1)                                   ; draw the total thing
  frame(wks)                                    ; now advance the frame
  
end
