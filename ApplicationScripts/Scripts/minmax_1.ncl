;************************************************
;  minmax_1.ncl 
;
; Concepts illustrated:
;   - Calculating the local minima/maxima of your data
;   - Adding meta data (attributes and coordinates) to a variable
;   - Using fbinrecread to read in fortran record data
;   - Spanning part of a color map for contour fill
;   - Drawing markers on a contour plot
;   - Using a blue-white-red color map
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin

;*******************
; read in lat/lon and time
;*******************
  lat=fbinrecread("latlon.dat",0,(/71/),"float")
  lat@long_name = "latitude"
  lat!0="lat" 
  lat&lat=lat
  nlat=dimsizes(lat)

  lon=fbinrecread("latlon.dat",1,(/144/),"float")
  lon@long_name = "longitude"
  lon!0="lon"
  lon&lon=lon
  nlon=dimsizes(lon)

  numrec = fbinnumrec("comppos.allmaps")
  time=ispan(1,numrec/2,1)
  ntim=dimsizes(time)
;******************
;read in psi
;******************   
  tmp = new( (/ntim,nlon,nlat/),float)
  k=0
  do i= 1,numrec-2,2
    tmp(k,:,:)=fbinrecread("comppos.allmaps",i,(/144,71/),"float")
    k=k+1
  end do
	
  tmp@long_name="psi+"
  tmp@units="10~S~8~N~m~S~2~N~s~S~-1~N"
  tmp=tmp/1.e6  ; 10^6 for anomalies 10^8 for regular psi
;***********************
; since this came from a binary file,
; we need to assign the coordinate
; variables
;***********************
  tmp!0="time"
  tmp&time=time

  tmp!1="lon"
  tmp&lon=lon

  tmp!2="lat"
  tmp&lat=lat
;******************
; reorder psi 
;****************** 
  psiav=new( (/nlat,nlon/),float)
  psiav=tmp(time|0,lat|:,lon|:)
;**************************************************
; calc min extrema : note already in anomaly form
;**************************************************
  locmin = local_min(psiav,False,0.)
  x=lon(locmin@xi)                ; get lat/lon points of minima
  y=lat(locmin@yi)
;*****************************************
; plot original data
;*****************************************
  wks  = gsn_open_wks("png","minmax")           ; send graphics to PNG file
  cmap = read_colormap_file("BlWhRe")           ; read color data
  ncolors = dimsizes(cmap(:,0))                 ; get number of colors

  res  = True
  res@cnFillOn             = True               ; turn on color fill
  res@cnFillPalette        = cmap(21:ncolors-25,:) ; subset color data and load map
  res@mpFillOn             = False              ; turn off gray continents
  res@gsnFrame             = False 
  plot = gsn_csm_contour_map_ce(wks,psiav,res)
;*****************************************
; plot min extrema over original data
;*****************************************
  polyres               = True          ; poly marker mods desired 
  polyres@gsMarkerIndex = 16            ; choose circle as polymarker
  polyres@gsMarkerSizeF = 5.0           ; select size to avoid streaking
  polyres@gsMarkerColor = (/"white"/)   ; choose color
  gsn_polymarker(wks,plot,x,y,polyres)  ; draw polymarkers
  frame(wks)
end




