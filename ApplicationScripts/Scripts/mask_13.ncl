;----------------------------------------------------------------------
; mask_13.ncl
;
; Concepts illustrated:
;   - Using a worldwide shapefile to create a land/ocean mask
;   - Using "mask" to set land or ocean values in your data to missing
;   - Masking a data array based on a geographical area
;   - Attaching shapefile polylines to a map plot
;   - Adding a _FillValue attribute to a variable
;----------------------------------------------------------------------
; Downloaded GSHHS shapefiles from:
;
;  http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/
;
; Used the "coarsest" one: "GSHHS_shp/c/GSHHS_c_L1.shp".
;
; This script depends on shapefile_utils.ncl" which can be
; downloaded from:
;
;  http://www.ncl.ucar.edu/Applications/Scripts/shapefile_utils.ncl
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  WRITE_MASK = False     ; Whether to write shapefile mask to file

;---Open file containing data to mask
  dir        = "./"
  cdf_prefix = "atmos"
  cdf_file   = dir + cdf_prefix + ".nc"
  fin        = addfile(cdf_file,"r")

;---Read "ts" and corresponding "ORO" mask.
  ts            = fin->TS(0,:,:)
  ts@_FillValue = default_fillvalue(typeof(ts))
  oro_mask      = fin->ORO(0,:,:)     ; ocean=0,land=1,sea_ice=2
;
; Create copy of "ts" with longitudes flipped. This
; is necessary for applying the shapefile mask, b/c
; the shapefile longitudes go from -180 to 180.
;
  ts_flip = lonFlip(ts)
;
; Create a mask array the same size as "ts", using
; lat/lon data read off a shapefile.
;
  shpfile  = "GSHHS_shp/c/GSHHS_c_L1.shp"    ; coarse

  opt             = True
  opt@return_mask = True
  shp_mask = shapefile_mask_data(ts_flip,shpfile,opt)
;
; Mask "ts" using "ORO" mask on file and shapefile
; land mask, for comparison.
;
  ts_shp_mask = where(shp_mask.eq.1,ts_flip,ts_flip@_FillValue)
  ts_oro_mask = where(oro_mask.eq.1,ts,     ts@_FillValue)
  copy_VarMeta(ts_flip,ts_shp_mask)
  copy_VarMeta(ts,     ts_oro_mask)

;---Start the graphics

  wks = gsn_open_wks("png","mask")           ; send graphics to PNG file

  res                       = True
  res@gsnMaximize           = True           ; maximize plot in frame
  res@gsnDraw               = False          ; don't draw plot yet
  res@gsnFrame              = False          ; don't advance frame yet

  res@cnFillOn              = True
  res@cnLineLabelsOn        = False
  res@cnLinesOn             = False
  res@cnFillPalette         = "matlab_jet"

;---Make sure all plots have same contour levels
  mnmxint                   = nice_mnmxintvl(min(ts),max(ts),25,False)
  res@cnLevelSelectionMode  = "ManualLevels"
  res@cnMinLevelValF        = mnmxint(0)
  res@cnMaxLevelValF        = mnmxint(1)
  res@cnLevelSpacingF       = mnmxint(2)

  res@lbLabelBarOn          = False
  res@gsnAddCyclic          = True

  res@mpFillOn              = False
  res@mpOutlineOn           = True

  res@gsnRightString        = ""
  res@gsnLeftString         = ""

;---Create plot of original data
  res@tiMainString = "Original data"
  ts_plot = gsn_csm_contour_map(wks,ts,res)

;---Create plot of original data masked by ORO
  res@tiMainString = "Original data masked by 'ORO' on file"
  ts_oro_plot = gsn_csm_contour_map(wks,ts_oro_mask,res)

;---For shapefile plot, use the shapefile outlines.
  res@mpOutlineOn  = False

;---Create plot of original data masked by shapefile outlines
  res@tiMainString = "Original data masked by shapefile outlines"
  ts_shp_plot = gsn_csm_contour_map(wks,ts_shp_mask,res)
  dum = gsn_add_shapefile_polylines(wks,ts_shp_plot,shpfile,False)

;---Draw all three plots on one page
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,(/ts_plot,ts_oro_plot,ts_shp_plot/),(/3,1/),pres)

  if(WRITE_MASK) then
    delete(fin)     ; Close file before we open again.
;
; Make copy of file so we don't overwrite original.
; This is not necessary, but it's safer.
;
    new_cdf_file = cdf_prefix + "_with_mask.nc"
    system("/bin/cp " + cdf_file + " " + new_cdf_file)
    finout = addfile(new_cdf_file,"w")
    filevardef(finout, "land_mask", typeof(shp_mask), (/ "lat", "lon" /) )
    finout->land_mask = (/shp_mask/)
  end if
end

