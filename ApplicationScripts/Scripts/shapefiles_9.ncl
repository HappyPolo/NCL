;*************************************************
; shapefiles_9.ncl
;
; Concepts illustrated:
;   - Masking a data array based on a geographical area obtained from a shapefile
;   - Calculating an areal time series
;   - Drawing a time series plot
;
;*************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;---Open shapefile and read lat/lon values.
  dir     = ncargpath("data") + "/shp/"
  f       = addfile(dir + "mrb.shp", "r")
  shp_lon = tofloat( f->x )
  shp_lat = tofloat( f->y )
  nshp    = dimsizes(shp_lon)

;---Shape file lon are -180 to 180                  
;   Make them 0-360 to match the GPCP grid

  shp_lon = where(shp_lon.lt.0, shp_lon + 360, shp_lon)

;---Get Max & Min lat/lon for the shape file 

  min_shp_lat = min(shp_lat) 
  max_shp_lat = max(shp_lat)
  min_shp_lon = min(shp_lon)
  max_shp_lon = max(shp_lon)

;---Open GPCP data file 
;   Use NCL syntax to extract the smallest are that includes the shape file

  fili    = "V22_GPCP.1979-2010.nc"

  fd      = addfile(fili,"r")
  prc     = fd->PREC(:,{min_shp_lat:max_shp_lat},{min_shp_lon:max_shp_lon})
  printVarSummary(prc)

  dimp    = dimsizes(prc)
  ntim    = dimp(0)
  nlat    = dimp(1)
  mlon    = dimp(2)

;---Create an array and initialize to _FillValue
  pmask   = new(dimsizes(prc), typeof(prc), prc@_FillValue)  
  copy_VarCoords(prc,pmask)

;---Keep only data within the polygon
;   Use NCL array syntax (:) to propagate to all times

  do nl=0,nlat-1
    do ml=0,mlon-1
      if(gc_inout(prc&lat(nl),prc&lon(ml),shp_lat,shp_lon)) then
         pmask(:,nl,ml) = prc(:,nl,ml)   
      end if
    end do
  end do

;---Compute weighted areal means and overall mean

  clat    = cos( 0.017453293* pmask&lat)   ; use simple cosine weighting

  pts     = wgt_areaave_Wrap(pmask, clat, 1.0, 1) 
  pts@long_name = "Monthly areal avg precip over Mississippi River Basin"

  pts_avg = avg(pts)

;---- PLOT

 wks    = gsn_open_wks ("png","shapefiles")       ; send graphics to PNG file
 yrfrac = yyyymmdd_to_yyyyfrac(fd->date, 0.)

 res                   = True                     ; plot mods desired
 res@tiMainString      = "GPCP: Mississippi River Basin"
;res@xyLineThicknessF  = 3.0
 res@vpHeightF         = 0.5                      ; change aspect ratio of plot
 res@vpWidthF          = 0.75                 
 res@trXMinF           = yrfrac(0)
 res@trXMaxF           = yrfrac(ntim-1)
 res@gsnCenterString   = fili
 res@gsnYRefLine       = pts_avg
 res@tiYAxisString     = pts@units 
 res@gsnAboveYRefLineColor = "red"              ; above ref line fill red
 res@gsnBelowYRefLineColor = "blue"             ; below ref line fill blue
  
 plot  = gsn_csm_xy (wks,yrfrac,pts,res) 
end
