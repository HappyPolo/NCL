; ***********************************************
; xy_5.ncl
;
; Concepts illustrated:
;   - Adding a separate curve to an XY plot using gsn_polyline
;   - Drawing a Y reference line in an XY plot
;   - Filling the areas of an XY curve above and below a reference line
;   - Changing the width and height of a plot
;   - Creating a new date array to use in a plot
;   - Using named colors to indicate a fill color
;   - Changing the title on the Y axis
;   - Creating a main title
;   - Changing the size/shape of an XY plot using viewport resources
;   - Setting the mininum/maximum value of the Y axis in an XY plot
;
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; ***********************************************
begin
  f     = addfile ("soi.nc" , "r") 
  dsoik = f->DSOI_KET              ; Darwin SOI Index via KET 11pt Smth
  dsoid = f->DSOI_DEC              ; Darwin Decadal SOI Index
; ***********************************************
; create new date array for use on the plot
; ***********************************************
  date  = f->date
  dimDate = dimsizes(date)
  dateF   = new (dimDate,float)   ; convert integer YYYYMM to float
  do n=0,dimDate-1       
    yyyy      = date(n)/100 
    mon       = date(n)-yyyy*100
    dateF(n) = yyyy + (mon-1)/12.  
  end do
;*********************************
; plot parameters
;*********************************
  wks          = gsn_open_wks ("png","xy") ; send graphics to PNG file

  res          = True                   ; plot mods desired
  res@gsnFrame = False                  ; don't advance frame yet      

  res@vpHeightF= 0.4                    ; change aspect ratio of plot
  res@vpWidthF = 0.8                  
  
  res@trYMinF  = -3.0                   ; min value on y-axis
  res@trYMaxF  =  3.0                   ; max value on y-axis

; since we stretch the plot, we need to slide it over a bit so it does not
; run off the page. we do this by:

  res@vpXF     = 0.1                   ; start plot at x ndc coord 
  
  res@tiYAxisString    = "Anomalies"    ; y-axis label      
  res@tiMainString     = "Darwin Southern Oscillation Index" ; title
  
; create a reference line and shade values above and below with 
; selected colors. This is shading array dsoid.
  res@gsnYRefLine           = 0.0             ; create a reference line   
;*********************************
; polyline parameters used on both plots
;*********************************
  polyres                  = True
  polyres@gsLineThicknessF = 3.0
;*********************************
; first plot in color
;*********************************
  res@gsnAboveYRefLineColor = "red"              ; above ref line fill red
  res@gsnBelowYRefLineColor = "blue"             ; below ref line fill blue
  plot = gsn_csm_xy (wks,dateF,dsoik,res)        ; create plot
  gsn_polyline(wks,plot,dateF,(/dsoid/),polyres) ; add polyline
  frame(wks)                                     ; now advance frame

;*********************************
; second plot in b&w
;*********************************
  res@gsnAboveYRefLineColor = "gray25"           ; above ref line fill red
  res@gsnBelowYRefLineColor = "gray75"          ; below ref line fill blue
  plot = gsn_csm_xy (wks,dateF,dsoik,res)        ; create plot
  gsn_polyline(wks,plot,dateF,(/dsoid/),polyres) ; add polyline
  frame(wks)   
end
