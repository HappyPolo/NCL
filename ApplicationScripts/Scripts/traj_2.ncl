;*************************************************
; traj_2.ncl
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************************
begin
;*************************************
; read in data
;************************************
; note this trajectory file contains data in the form of
; 9 variables x 131 timesteps x 100 trajectories

; The traj.bin file is missing, so traj_data.nc is used instead.
;    ntime = 131
;    big = fbinrecread("traj.bin",0,(/9,ntime,100/),"float")
;    time= fbinrecread("traj.bin",1,(/ntime/),"float")


   f        = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/traj_data.nc","r")
   salinity = f->sdata
   sdims    = dimsizes(salinity)
;********************************************
   wks = gsn_open_wks("png","traj")               ; send graphics to PNG file
;*********************************************
; color preps
;*********************************************
  cnLevels=fspan(34.5,34.8,8)
  cmap = RGBtoCmap ("redyellowblue.rgb")
  gsn_define_colormap (wks,cmap)

   res            = True                          ; map resources
   res@gsnDraw    = False                         ; don't draw
   res@gsnFrame   = False                         ; don't advance frame
   res@vpWidthF   = 0.80                          ; make map bigger
   res@vpHeightF  = 0.80
   res@mpMaxLatF  = -20                           ; select subregion
   res@mpMinLatF  = -60 
   res@mpMinLonF  = -75
   res@mpMaxLonF  = -25

; label bar resources 
   res_lb                    = True
   res_lb@vpWidthF           = 0.60
   res_lb@vpHeightF          = 0.10
   res_lb@lbPerimOn          = False            ; Turn off perimeter.
   res_lb@lbOrientation      = "Horizontal"     ; Default is vertical.
   res_lb@lbLabelStride      = 2    
   res_lb@lbLabelAlignment   = "InteriorEdges"  ; Default is "BoxCenters".
   res_lb@lbFillColors       = cmap(2:,:)       ; Colors for boxes.
   res_lb@lbMonoFillPattern  = True             ; Fill them all solid.
   res_lb@lbLabelFontHeightF = 0.015 

   res@tiMainString    = "Trajectories colored by salinity (ppt)"  ; title
   res@mpDataBaseVersion     = "MediumRes"               ; better map outlines
   res@pmTickMarkDisplayMode = "Always"                  ; better map tickmarks

  
   map = gsn_csm_map_ce(wks,res)                         ; create map
;*********************************************
; trajectory parameters
;*********************************************
   traj = (/1,10,53,67,80/)          ; choose which trajectories to plot

;*********************************************
; some plot parameters
;*********************************************
   pres                  = True               ; polyline resources
   pres@gsLineThicknessF = 2.0                ; line thickness

   mres  = True                               ; marker resources
   first = True                               ; start of traj resources
;********************************
   do i = 0,dimsizes(traj)-1                  ; loop through chosen traj
      ypt = salinity(2,:,traj(i))                  ; extract lat from whole array
      xpt = salinity(1,:,traj(i))                  ; extract lon from whole array
      sst = salinity(8,:,traj(i))

     do j=0,dimsizes(ypt)-2
        pres@gsLineColor=GetFillColor(cnLevels,cmap,avg( (/sst(j),sst(j+1)/)))
        gsn_polyline(wks,map,(/xpt(j),xpt(j+1)/),(/ypt(j),ypt(j+1)/),pres) 
     end do


; create a unique marker to indicate the start of the trajectory

      first@gsMarkerSizeF  = 9.0         ; marker size
      first@gsMarkerColor  = "red"     ; marker color

      gsn_polymarker(wks,map,xpt(0),ypt(0),first) ; draw start of traj
      delete(first@gsMarkerColor)
      delete(first@gsMarkerSizeF)
   end do 
   gsn_labelbar_ndc(wks,dimsizes(cnLevels)+1,cnLevels,0.30,0.30,res_lb)  
   draw(map)                                           
   frame(wks)                                         
  
end

