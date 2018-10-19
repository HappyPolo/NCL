;----------------------------------------------------------------------
; This script masks data over part of Greenland, using outlines from 
; a shapefile downloaded from http://www.gadm.org/country/
;
; It can be slow to run, maybe 30 seconds or more.
;
; The GRL_adm0.shp/GRL_adm1.shp shapefiles have the following 
; lat/lon min/max values:
;
;    lat min =  59.74450683593795   max = 83.65833282470737
;    lon min = -73.24323272705044   max = -0.0130208618937786
;
; We use these to help speed up the masking, since the original data
; is  global and can take a long time to mask. Greenland requires a
; LOT of lat/lon points to define its rugged coastline.
;----------------------------------------------------------------------
load "shapefile_utils.ncl"     ; script that contains the masking function

begin
  PLOT_MARKERS = True      ; Whether to draw markers at grid locations.
                           ; This is useful if you want to see which points
                           ; the masking algorithm keeps.

;----------------------------------------------------------------------
; Rough area of interest for plotting and masking. This will make 
; masking routine go faster. You can use different values for 
; plotting and masking, if desired.
;----------------------------------------------------------------------
  minlat    =  58
  maxlat    =  85
  minlon    = -75
  maxlon    =   0

;---Open the file and read first timestep of "ts".
  fname = "ts_Amon_CESM1-CAM5_historical_r1i1p1_185001-200512.nc"
  f     = addfile(fname,"r")
  t     = f->ts(0,:,:)
  t     = lonFlip(t)              ; 0 to 360 ---> -180 to 180

;----------------------------------------------------------------------
; Mask "t" based on the "Tunu" Greenland outline defined in the
; "GRL_adm1.shp" shapefile. 
;----------------------------------------------------------------------
;  shp_filename    = "GRL_adm/GRL_adm1.shp"
;  shp_varname     = "NAME_1"
  shp_filename    = "GRL_adm/GRL_adm2.shp"
  shp_varname     = "NAME_2"
  opt             = True
;  opt@shape_var   = shp_varname
;  opt@shape_names = (/"Ammassalik","Illoqqortoormiut"/)
  opt@minlat      = minlat        ; This helps the masking
  opt@maxlat      = maxlat        ; go faster.
  opt@minlon      = minlon
  opt@maxlon      = maxlon
  
  tmask = shapefile_mask_data(t,shp_filename,opt)
  printVarSummary(tmask)
  printMinMax(tmask,0)


  print("Average of 'ts' over whole region  = " + avg(t))
  print("Average of 'ts' over masked region = " + avg(tmask))

;---Start the graphics
  wks = gsn_open_wks("png","greenland_mask")

  res                   = True
  res@gsnMaximize       = True          ; make plot as large as possible
  res@gsnDraw           = False         ; Turn these off so we can add
  res@gsnFrame          = False         ; shapefile outlines before drawing.

  res@cnFillOn          = True          ; turn on color fill
  res@cnLinesOn         = False         ; turn off contour lines

  res@tiMainString      = fname         ; use the file name as the main title

  res@mpDataBaseVersion = "MediumRes"   ; better map outlines
  res@mpMinLatF         = minlat        ; zoom in on Greenland
  res@mpMaxLatF         = maxlat
  res@mpMinLonF         = minlon
  res@mpMaxLonF         = maxlon
  res@mpFillOn          = False         ; Turn off map fill and outlines.
  res@mpOutlineOn       = False         ; Will add shapefile outlines.

;---Create plots of original and masked data
  plot      = gsn_csm_contour_map(wks,t,res)
  plot_mask = gsn_csm_contour_map(wks,tmask,res)

;---Attach shapefile outlines to both plots
  lnres                  = True
  lnres@gsLineThicknessF = 2.0
  id1 = gsn_add_shapefile_polylines(wks,plot,"GRL_adm/GRL_adm0.shp",lnres)
  id2 = gsn_add_shapefile_polylines(wks,plot_mask,"GRL_adm/GRL_adm0.shp",lnres)

;---Draw both plots in one panel
  pres                = True
  pres@gsnMaximize    = True          ; make plot as large as possible
  gsn_panel(wks,(/plot,plot_mask/),(/2,1/),pres)

;---Add markers at grid locations, if desired.
  if(PLOT_MARKERS) then
    mkres                   = True
    mkres@gsMarkerSizeF     = 5
    mkres@gsnCoordsAttach   = True
    gsn_coordinates(wks,plot,t,mkres)

;---Draw points outside masked area in red.
    mkres@gsnCoordsMissingColor = "red"
    gsn_coordinates(wks,plot_mask,tmask,mkres)

    gsn_panel(wks,(/plot,plot_mask/),(/2,1/),pres)
  end if

end
