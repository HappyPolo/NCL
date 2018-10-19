;************************************************* 
; traj_1.ncl
;
; Concepts illustrated:
;   - Plotting trajectories
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;**************************************************
begin
;*************************************
; read in data
;************************************
; note this trajectory file contains data in the form of
; 9 variables x 131 timesteps x 100 trajectories
   f        = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/traj_data.nc","r")
   salinity = f->sdata
   sdims    = dimsizes(salinity)
   ntime    = dimsizes(sdims(1))

;********************************************
   wks = gsn_open_wks("png","traj")               ; send graphics to PNG file
   res            = True                          ; map resources
   res@gsnDraw    = False                         ; don't draw
   res@gsnFrame   = False                         ; don't advance frame
   res@vpWidthF   = 0.80                          ; make map bigger
   res@vpHeightF  = 0.80
   res@mpMaxLatF  = -20                           ; select subregion
   res@mpMinLatF  = -60 
   res@mpMinLonF  = -75
   res@mpMaxLonF  = -25

   res@tiMainString    = "Example of a trajectory plot"  ; title
   res@gsnCenterString = "markers every 4th time step"   ; center string
  
   res@mpDataBaseVersion     = "MediumRes"               ; better map outlines
   res@pmTickMarkDisplayMode = "Always"                  ; better map tickmarks

   map = gsn_csm_map_ce(wks,res)                         ; create map
;*********************************************
; trajectory parameters
;*********************************************
   traj = (/1,10,53,67,80/)          ; choose which trajectories indexes to plot
;*********************************************
; some plot parameters
;*********************************************
   pres                  = True               ; polyline resources
   pres@gsLineThicknessF = 2.0                ; line thickness
   colors= (/"red","blue","dark green","grey","magenta"/) ; line color

   mres  = True                               ; marker resources
   first = True                               ; start of traj resources
;********************************
   c=0                                        ; counter variable
   do i = 0,dimsizes(traj)-1                  ; loop through chosen traj
      ypt = salinity(2,:,traj(i))             ; extract lat from whole array
      xpt = salinity(1,:,traj(i))             ; extract lon from whole array

      pres@gsLineColor = colors(c)            ; line color for this traj
      c=c+1                                   ; advance counter
      gsn_polyline(wks,map,xpt,ypt,pres)      ; draw the traj

; add markers to the trajectories

      mres@gsMarkerIndex  = 16           ; marker style (circle)
      mres@gsMarkerSizeF  = 4.0          ; marker size
      mres@gsMarkerColor  = "black"      ; maker color
      gsn_polymarker(wks,map,xpt(::4),ypt(::4),mres) ; draw every 4th marker

; create a unique marker to indicate the start of the trajectory

      first@gsMarkerSizeF  = 8.0         ; marker size
      first@gsMarkerColor  = "green"     ; marker color

      gsn_polymarker(wks,map,xpt(0),ypt(0),first) ; draw start of traj
   end do 
   draw(map)                                           
   frame(wks)                                         
  
end


