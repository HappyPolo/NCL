;*********************************************
; polyg_3.ncl
;
; Concepts illustrated:
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Zooming in on a particular area on a cylindrical equidistant map
;   - Manually creating lat/lon coordinate arrays
;   - Attaching markers to a contour plot
;   - Drawing buoy locations on a contour/map plot
;   - Spanning part of a color map for contour fill
;
;********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;********************************
; get data
;********************************
  in  = addfile("w128_sst.nc","r")
  sst           = in->SST
  sst@long_name = "SST"
  sst@units     = "degC"
  lat           = in->lat
  lon           = in->lon
;********************************
; select sub-regions
;********************************
  minlat=-41
  maxlat=-27
  minlon=36.0
  maxlon=48.0

  orig           = sst({minlat:maxlat},{minlon:maxlon})
  orig&lat@units = "degrees_north"   ; Need to add these for the
  orig&lon@units = "degrees_east"    ; map overlay to work properly.

  sublat = lat({minlat:maxlat})
  sublon = lon({minlon:maxlon})

;********************************
; get bouy locations
;********************************
  fin = addfile("bouy_h01.2R9_899.nc","r")
  bouys = fin->BOUYS
  bmask = bouys({minlat:maxlat},{minlon:maxlon})
;********************************
; sub-sample data over bouy locations
;********************************
  sub   = mask(orig,bmask,1)
  sub!0="lat"
  sub!1="lon"
  sub&lat=sublat
  sub&lon=sublon
  nlat=dimsizes(sublat)
  nlon=dimsizes(sublon)
;************************************
; create oned arrays for poly markers
;************************************
  sub1d  = ndtooned(sub)
  npts   = dimsizes(ind(.not.ismissing(sub1d)))
  global = nlon*nlat                   ; create 1D array 
  glat=new(global,float)               ; allocate memory
  glon=new(global,float)

  glon = onedtond(sublon,(/global/))   ; repeat lon_t to fill glon 

  do i=0,nlon-1                        ; repeat lat_t to file glat
     glat(i:global-1:nlon)=sublat
  end do

  inds = ind(.not.ismissing(sub1d))    ; convert rmask to 1D array
;********************************
; create plot
;********************************
   wks = gsn_open_wks("png","polyg" )         ; send graphics to PNG file

   cmap = read_colormap_file("rainbow")       ; read colormap

   
   res                 = True 

   res@cnFillOn        = True               ; color plot desired
   res@cnLineLabelsOn  = False              ; turn off line labels 
   res@cnLinesOn       = False              ; turn off contour lines
   res@cnFillPalette   = cmap(10:,:)        ; subset the color map

   res@gsnAddCyclic     = False             ; turn off cyclic point
   res@mpMinLatF        = minlat            ; select subregion
   res@mpMaxLatF        = maxlat
   res@mpMinLonF        = minlon
   res@mpMaxLonF        = maxlon

   res@gsnDraw          = False             ; so we can add poly stuff
   res@gsnFrame         = False

   res@lbLabelStride    = 5                 ; reduce # labels
   res@lbBoxLinesOn     = False             ; turn off box lines

   res@cnLevelSpacingF  = .5                ; set contour spacing

   res@tiMainString     = "Agulhas Retroflection" ; titles
   res@gsnCenterString  = "Buoy locations"
;********************************
; plot original data
;********************************
   polyres                   = True
   polyres@gsMarkerIndex     = 16          ; polymarker style
   polyres@gsMarkerSizeF     = 5.          ; polymarker size


   plot    = gsn_csm_contour_map_ce(wks,orig,res)
   dum1    = gsn_add_polymarker(wks,plot,glon(inds),glat(inds),polyres)
   draw(plot)
   frame(wks)
end
