;----------------------------------------------------------------------
; goes_3.ncl
;
; Concepts illustrated:
;   - Reading a GOES-15 file
;   - Fixing the lat, lon and data values so that outliers are recognized
;   - Using triangular mesh to create contours
;----------------------------------------------------------------------
; Because the lat/lon arrays have missing values, it is necessary to
; plot this data with res@trGridType set to "TriangularMesh".
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;---read variable
   diri = "./"
   fili = "goes15.2012.212.030018.BAND_04.nc"
   f    = addfile(diri+fili,"r")
   d    = f->data          ; float data(time, yc, xc) ;
                           ; data:type = "VISR" ;
                           ; associate coordinates with variable
                           ; fix data
   lat  = f->lat
   lon  = f->lon

   d@_FillValue   = 255.
   lat@_FillValue = 1e9   ; to fix weird 2.14329e+09 values
   lon@_FillValue = 1e9
   lat  = where(lat.gt.lat@_FillValue, lat@_FillValue, lat)
   lon  = where(lon.gt.lon@_FillValue, lon@_FillValue, lon)
;
; The longitudes cross the dateline, so "fix" them here.
; This is so we can center the plot correctly later.
;
   lon = where(lon.lt.0,lon+360,lon)

;---Subscript the array to make plotting faster.
   SUBSET = True   ; This plot can take a LONG time if you use full domain.
   nt     = 0
   if(SUBSET) then
     nstep      = 10                   ; Use whatever step you like
     dsub       = d(nt,::nstep,::nstep)
     dsub@lat2d = lat(::nstep,::nstep)
     dsub@lon2d = lon(::nstep,::nstep)
     delete([/lat,lon/])
   else
     dsub       = d(nt,:,:)
     dsub@lat2d = lat
     dsub@lon2d = lon
     delete([/d,lat,lon/])
   end if 

   lat2d_min = min(dsub@lat2d)
   lat2d_max = max(dsub@lat2d)
   lon2d_min = min(dsub@lon2d)
   lon2d_max = max(dsub@lon2d)

;---Create plot
   wks = gsn_open_wks("png", "goes")

   res                     = True
   res@cnFillOn            = True            ; turn on color
   res@cnFillPalette       = "amwg"          ; set color map
   res@cnFillMode          = "CellFill"
   res@cnLinesOn           = False           ; Turn off contour lines

   res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
                                                ; arrays have missing values.

   res@gsnSpreadColors     = True            ; use full colormap
   res@gsnAddCyclic        = False           ; data not cyclic
   res@gsnMaximize         = True            ; ps, pdf, pdf    
   res@lbOrientation       = "Vertical"      ; just for something different
   res@pmTickMarkDisplayMode = "Always"      ; use NCL default 

   res@mpMinLatF           = lat2d_min
   res@mpMaxLatF           = lat2d_max
   res@mpMinLonF           = lon2d_min
   res@mpMaxLonF           = lon2d_max
   res@mpCenterLonF        = (lon2d_min+lon2d_max)/2.

   res@mpFillOn            = False
   res@mpOutlineBoundarySets = "National"    ; turn on country boundaries

   res@tiMainString         = fili
   res@gsnLeftString        = dsub@type

   plot = gsn_csm_contour_map(wks,dsub,res)

end
