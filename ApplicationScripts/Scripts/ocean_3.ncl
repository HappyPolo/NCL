;************************************
;
; CSM_Graphics: ocean_3.ncl
;
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
;************************************
begin
;************************************
 in = addfile("h_avg_Y0191_D000.00.nc","r")
 lat_t=in->lat_t                     ; read in lat and lon
 lon_t=in->lon_t({0:360})
;************************************
; get array dimensions
;************************************
 nlat=dimsizes(lat_t)
 nlon=dimsizes(lon_t)
;************************************
; create array of land mask points
;************************************
  global = nlon*nlat                 ; create 1D array 
  glat=new(global,float)             ; allocate memory
  glon=new(global,float)

  glon = onedtond(lon_t,(/global/))  ; repeat lon_t to fill glon 

  do i=0,nlon-1                      ; repeat lat_t to file glat
    glat(i:global-1:nlon)=lat_t
  end do

  rmask=in->rmask(:,{0:360})   ; read in rmask 
  indexes = (/0,1,2,3,6,8,9,10/)   ; Values we want to color in rmask array.
  colors  = (/"gray","blue","green","red","hotpink","coral","magenta","aquamarine"/)
;************************************
; create contour plot
;************************************
 wks = gsn_open_wks("ncgm","ocean")  ; open a ncgm file
 res=True                            ; map mods desired
 res@mpFillOn             = False    ; turn off gray continents
 res@mpOutlineOn          = False    ; turn off continental outline
 res@gsnFrame             = False    ; do not advance frame
 plot = gsn_csm_map_ce(wks,res)      ; create plot
;************************************
; run through all the colors
;************************************
  maskres = True
  maskres@gsMarkerIndex = 16 
  do i=0,dimsizes(indexes)-1
     inds  = ind(ndtooned(rmask).eq.indexes(i)) 
     maskres@gsMarkerColor = colors(i)
     gsn_polymarker(wks,plot,glon(inds),glat(inds),maskres)
     delete(inds)
  end do
frame(wks)
end



