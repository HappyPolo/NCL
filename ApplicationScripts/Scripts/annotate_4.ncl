;********************************************************
; annotate_4.ncl
;
; Concepts illustrated:
;   - Plotting trajectories
;   - Attaching a custom legend to a map
;   - Attaching markers, text, and polylines to a map
;   - Changing the width and height of a legend
;   - Drawing filled dots on a map
;
; This script was contributed by Yongzuo Li from
; the University of Oklahoma.
; 
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;**************************************************
begin

   xp = new((/5,4/),float)            ; allocate memory
   yp = new((/5,4/),float)

;best track
   yp(0,:) = (/ 29.1,   30.3,   31.7,   33.5/)
   xp(0,:) = (/-94.6,  -95.2,  -95.3,  -94.9/)
;da
   yp(1,:) = (/ 29.12,  30.02,  31.29,  33.05/)
   xp(1,:) = (/-94.87, -95.08, -95.13, -94.65/)
;wrfUgfs
   yp(2,:) = (/ 29.03,  30.29,  31.56,  33.05/)
   xp(2,:) = (/-94.62, -95.34, -95.45, -95.14/)
;3dvar
   yp(3,:) = (/ 29.03,  30.47,  32.46,  34.32/)
   xp(3,:) = (/-94.62, -94.29, -94.38, -93.70/)

;********************************************
   wks      = gsn_open_wks("png","annotate")       ; send graphics to PNG file

   res             = True
   res@gsnDraw     = False                         ; don't draw
   res@gsnFrame    = False                         ; don't advance frame
   res@gsnMaximize = True

   res@mpFillOn              = False
   res@mpPerimOn             = True
   res@mpOutlineBoundarySets = "GeophysicalAndUSStates"
   res@pmTickMarkDisplayMode = "Always"

   res@mpLimitMode = "LatLon"        ; select subregion
   res@mpMinLatF   = 28 
   res@mpMaxLatF   = 36                
   res@mpMinLonF   = -100
   res@mpMaxLonF   = -90

   res@tmYROn      = False     ; turn off right and top tickmarks
   res@tmXTOn      = False

   res@tiMainString      = "Hurricane Ike track"  ; title
   res@tiMainFontHeightF = 0.02

   map = gsn_csm_map_ce(wks,res)                  ; create map

; Set up some legend resources.
   lgres                    = True
   lgres@lgLineColors       = (/"black","red","green","blue"/)
   lgres@lgLineThicknessF   = 2. 
   lgres@lgLabelFontHeightF = .08            ; set the legend label font thickness
   lgres@vpWidthF           = 0.15           ; width of legend (NDC)
   lgres@vpHeightF          = 0.1            ; height of legend (NDC)
   lgres@lgMonoDashIndex    = True   
   lgres@lgPerimColor       = "orange"       ; draw the box perimeter in orange
  ;lgres@lgPerimThicknessF = 3.0            ; thicken the box perimeter
   labels = (/"Best track","Hybrid","pureGFS","3DVAR"/)

; Create the legend.
   lbid   = gsn_create_legend(wks,4,labels,lgres)         ; create legend

; Set up resources to attach legend to map.
   amres = True
   amres@amParallelPosF   =  0.27 	         ; positive move legend to the right
   amres@amOrthogonalPosF = -0.35                 ; positive move the legend down
   annoid1 = gsn_add_annotation(map,lbid,amres)   ; attach legend to plot
 
; Add text of every 6 hours  
   txres               = True
   txres@txFontHeightF = 0.015        
   txres@txFontColor   = "black"
   text1 = gsn_add_text(wks,map,"06",xp(0,0)+0.1,yp(0,0)+0.1,txres)
   text2 = gsn_add_text(wks,map,"12",xp(0,1)+0.15,yp(0,1),txres)
   text3 = gsn_add_text(wks,map,"18",xp(0,2)+0.15,yp(0,2),txres)
   text4 = gsn_add_text(wks,map,"00",xp(0,3),    yp(0,3)+0.1,txres)

; Add trajectory lines.
   pres                  = True               ; polyline resources
   pres@gsLineThicknessF = 3.0                ; line thickness
   pres@gsLineColor      = "black"
   line1 = gsn_add_polyline(wks,map,xp(0,:),yp(0,:),pres)      ; draw the traj

   pres                  = True               ; polyline resources
   pres@gsLineColor      = "red"
   line2 = gsn_add_polyline(wks,map,xp(1,:),yp(1,:),pres)      ; draw the traj

   pres                  = True               ; polyline resources
   pres@gsLineColor      = "green"
   line3 = gsn_add_polyline(wks,map,xp(2,:),yp(2,:),pres)      ; draw the traj

   pres                  = True               ; polyline resources
   pres@gsLineColor      = "blue"
   line4 = gsn_add_polyline(wks,map,xp(3,:),yp(3,:),pres)      ; draw the traj

; Add markers to the trajectories.
   mres                = True         ; marker resources for best track
   mres@gsMarkerIndex  = 16           ; marker style (filled circle)
   mres@gsMarkerSizeF  = 8.0          ; marker size
   mres@gsMarkerColor  = "black"      ; maker color
   markers = gsn_add_polymarker(wks,map,xp(0,:),yp(0,:),mres)

   draw(map)                                           
   frame(wks)                                         
  
end

