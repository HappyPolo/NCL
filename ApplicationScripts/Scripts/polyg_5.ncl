; ===============================================
; polyg_5.ncl
;
; Concepts illustrated:
;   - Filling the area between two curves in an XY plot
;   - Attaching a filled polygon to an XY plot
;   - Drawing Greek characters on an XY plot
;
; ===============================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;================================================
begin
;================================================
; file handling and data aquisition
;================================================
 in    = addfile("80.nc","r")
 TS    = in->TS(0,:,:)
 nlat  = dimsizes(TS&lat)          
;================================================
; define a polygon centered the width of 2 sigma
;================================================
 xp    = new( (/2*nlat/), float )
 yp    = new( (/2*nlat/), float )
 do k=0,nlat-1
   dx = sqrt(TS(k,{60}))
   yp(k) = TS(k,{60}) + dx
   xp(k) = TS&lat(k)
   xp(2*nlat-1-k) = TS&lat(k)
   yp(2*nlat-1-k) = TS(k,{60}) - dx
 end do
;================================================ 
; plotting parameters
;================================================
 wks   = gsn_open_wks ("png", "polyg" )           ; send graphics to PNG file

 res                    = True                    ; plot mods desired
 res@gsnDraw            = False                   ; don't draw
 res@gsnFrame           = False                   ; don't advance frame
 res@xyLineThicknessF   = 2.                      ; line thickness
 res@tfPolyDrawOrder    = "Predraw"               ; put line on top 

; note that a colon is the default function code, but I have personally
; set the default code to be a tilda (~) in my .hluresfile

 res@tiMainString       = "A Title with ~F33~helas ~F21~Characters~"
 plot  = gsn_csm_xy (wks,TS&lat,TS(:,{60}),res)   ; create plot

 gsres                   = True                        ; poly res
 gsres@gsFillColor       = "SlateBlue"                 ; color chosen
 dummy = gsn_add_polygon (wks,plot,xp,yp,gsres)
 
;=================================================
; add greek symbol to plot with gsn_text
;=================================================
 txres               = True                      ; text mods desired
 txres@txFontHeightF = 0.07                      ; text font height
  
 gsn_text(wks,plot,"~F33~s",-50,240,txres)

 draw(plot)                                            ; draw
 frame(wks)                                            ; advance frame

end
