;*************************************************
; regress_7.ncl
;
; Concepts illustrated:
;   - Calculating a regression line
;   - Use  := syntax to handle changing array sizes
;   - Use 'tr' resources to fix the plot limits for easier comparison
;   - Drawing a scatter plot with a regression line for 2 data sets
;   - Create a panel plot
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

  diri  ="./"

;**********************************************************************
; plotting parameters
;**********************************************************************
  plot = new(2, "graphic")
  wks  = gsn_open_wks("png","regress")             ; send graphics to PNG file

  res                     = True                   ; plot mods desired
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@xyMarkLineModes     = (/"Markers","Lines"/)  ; choose which have markers
  res@xyMarkers           = 16                     ; choose type of marker 
  res@xyMarkerColor       = "red"                  ; Marker color
  res@xyMarkerSizeF       = 0.0075                 ; Marker size (default 0.01)
  res@xyDashPatterns      = 1                      ; solid line 
  res@xyLineThicknesses   = (/1,2/)                ; set second line to 2
  res@trYMinF             = 2.40
  res@trYMaxF             = 3.60
  res@trXMinF             = 460
  res@trXMaxF             = 720

  resP                    = True
  resP@gsnMaximize        = True                   ; maximize plot in frame

;**********************************************************************
; loop over each data set. Ues the := sytntax to handle changing size
;**********************************************************************

  do n=0,1
    if (n.eq.0) then
        N = 15 
    else
        N = 82
    end if

;**********************************************************************
; Because each data sets (iteration) contains different data sizes ue := 
;**********************************************************************

    fili  = "law_school_"+N+".txt"
    LSAT := asciiread(diri+fili, (/N,3/), "float")  ; 3 columns
    xx   := LSAT(:,1)    
    yy   := LSAT(:,2) 
    xx@long_name = "LSAT"
    yy@long_name = "GPA"
  
;**********************************************************************
; Calculate regression line and correlation. These are not order dependent
;**********************************************************************
    rc   := regline(xx,yy)    ; n=0, N=15; rc=0.00473 | n=1, N=82; rc=0.00473
    rr   := escorc(xx,yy)     ; n=0, N=15; rc=0.77451 | n=1, N=82; rr=0.75999

;**********************************************************************
; Markers do *not* require any ordering
; Plot lines do require that the abscissa be in monotonic order
; Sort the data into ascending order based on the abscissa
;**********************************************************************
  
    mono  = 1                            ; ascending=1 , descending=-1
    ii   :=  dim_pqsort_n(xx,mono,0)
    x    := xx(ii)                       ; ascending order 
    y    := yy(ii)
  
;**********************************************************************
; Create array to hold both the original data and calculated regression line.
;**********************************************************************
    data      := new ( (/2,dimsizes(yy)/), typeof(yy))
    data(0,:)  = yy
    data(1,:)  = rc*(x-rc@xave) + rc@yave           ; y = m*x + B
  
    res@tiMainString  = fili
    plot(n)    = gsn_csm_xy (wks,x,data,res)        ; create plot
  end do

;**********************************************************************
; Create the panel plot
;**********************************************************************
 ;resP@txString = ""
  resP@gsnMaximize = True
  gsn_panel(wks,plot,(/1,2/),resP)	

