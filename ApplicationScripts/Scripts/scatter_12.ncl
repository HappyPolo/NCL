;----------------------------------------------------------------------
; scatter_12.ncl
;
; Concepts illustrated:
;   - Drawing a simple scatter plot
;   - Create local functions to draw separate x and y 'error bars'
;   - Add the error bars to the associated  markers
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;----------------------------------------------------------------------
; Rashed Mahmood posted (11/2016) the original question to ncl-talk. 
; He then responded to his own post  with a successful script.
;
; Alan Brammer (U. Albany) created the following procedures.  
;----------------------------------------------------------------------
; local procedures to draw 'error bars' in the x and y direction
;----------------------------------------------------------------------
undef("add_x_errorbar")
procedure add_x_errorbar(wks, plot, x[*]:numeric,y[*]:numeric, xerror[*]:numeric, res)
local dimz, xpoints, ypoints, gsres, i
begin
  gsres = res       
  dimz  = dimsizes(y)

  xpoints = (/x-xerror, x+xerror/)
  ypoints = (/ y, y/)

  do i=0, dimz(0)-1
     plot@$tostring("x_errorbar"+i)$ = gsn_add_polyline(wks, plot, xpoints(:,i), ypoints(:,i), gsres )
  end do
end
;---
undef("add_y_errorbar")
procedure add_y_errorbar(wks, plot, x[*]:numeric,y[*]:numeric, yerror[*]:numeric, res)
local dimz, xpoints, ypoints, gsres, i
begin
  gsres = res
  dimz  = dimsizes(y)

  xpoints = (/x, x/)
  ypoints = (/ y-yerror, y+yerror/)
  do i=0, dimz(0)-1
     plot@$tostring("y_errorbar"+i)$ = gsn_add_polyline(wks, plot, xpoints(:,i), ypoints(:,i), gsres )
  end do
end

;===============================================
;                MAIN
;===============================================
begin                               ; 'begin' is optional optional

   x      = (/1.,2.,3./)            ; also: ispan(1,3,1) or fspan(1,3,3)
   y      = (/1.,2.,3./)          
   u1     = (/0.2,0.3,0.11/)         
   u2     = (/0.15,0.21,0.31/)    

   wks  = gsn_open_wks("png","scatter")   
   res  = True                   
   res@gsnDraw             = False
   res@gsnFrame            = False

   res@xyMarkLineModes     = "Markers"
   res@xyMarker            = 9
   res@xyMarkerSizeF       = 0.02                        ; default 0.01
   res@xyMarkerThicknessF  = 2.0                         ; default 1.00

   res@trYMinF             = 0.
   res@trYMaxF             = max(y)+0.2*max(y)           ; extra space for demo 
   res@trXMinF             = 0.
   res@trXMaxF             = max(x)+0.2*max(x)
   
   plot                    = gsn_csm_xy (wks,x,y,res)

   gsresx = True                                          ; add x error bars
   gsresx@gsLineColor      = "red"
   gsresx@gsLineThicknessF = 2.0
   add_x_errorbar(wks, plot, x, y, u1, gsresx)
    
   gsresy = True
   gsresy@gsLineColor      = "blue"                       ; add y error bars
   gsresy@gsLineThicknessF = 4.0
   add_y_errorbar(wks, plot, x, y, u2, gsresy)

   draw(plot)
   frame(wks)
end                                 ; required if 'begin' is used
