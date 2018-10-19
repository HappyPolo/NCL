;************************************
;
; CSM_Graphics: ocean_2.ncl
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
 T=in->T(0,0,:,{lon_t|0:360})        ; get rid of cyclic points
 lat_t=in->lat_t                     ; read in lat and lon
 lon_t=in->lon_t({lon_t|0:360})
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

  indexes=(/0/)                      ; choose rmask value to color in
  rmask=in->rmask(:,{lon_t|0:360})   ; read in rmask (must be same size as T!)
  inds = ind(ndtooned(rmask).eq.indexes) ; convert rmask to 1D array
;************************************
; create contour plot
;************************************
 wks = gsn_open_wks("ncgm","ocean")  ; open a ncgm file
 res=True                            ; map mods desired
 res@mpFillOn             = False    ; turn off gray continents
 res@mpOutlineOn          = False    ; turn off continental outline
 res@gsnFrame             = False    ; do not advance frame
 plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot
;************************************
; draw polymarkers for land mask
;************************************
 polyres=True                        ; poly marker mods desired     
 polyres@gsMarkerIndex=16            ; choose circle as polymarker
 polyres@gsMarkerSizeF=7.0           ; select size to avoid streaking
 colors  = (/"gray"/)                ; choose color
 polyres@gsMarkerColor=colors        ; set polymarker color
 gsn_polymarker(wks,plot,glon(inds),glat(inds),polyres) ; draw polymarkers
 frame(wks)
end



