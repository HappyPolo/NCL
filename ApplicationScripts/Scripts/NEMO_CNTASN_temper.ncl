;----------------------------------------------------------------------
; If you want to draw the shapefile outlines in this script, you
; must download the "country bounaries" shapefile data from
; http://www.diva-gis.org/Data/.  Otherwise, set USE_SHAPEFILE to False.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  USE_SHAPEFILE = True

  filename = "CNTASN_1m_200103_grid_T.nc"
  f        = addfile (filename, "r")
  v        = f->votemper            ; (time_counter, deptht, y, x) 
  lat2d    = f->nav_lat             ; (y,x)
  lon2d    = f->nav_lon             ; (y,x)
  nt       = 0                      ; time index to plot
  nd       = 0                      ; depth index to plot

;---Convert 'time' coordinate array to better units
  date = cd_calendar(v&time_counter, -3)   ; YYYYMMDDHH

;---Start the graphics
  wks = gsn_open_wks("ps" ,"NEMO_CNTASN_temper")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")     ; change color map

;---Set some resources
  res              = True

  if(USE_SHAPEFILE) then
;---Use shapefile map outlines (slower)
    res@gsnDraw       = False     ; Will draw later after shapefile
    res@gsnFrame      = False     ; outlines are attached.
    res@tiMainString  = filename + " (with shapefile outlines)"
    res@mpOutlineOn   = False
  else
;---Use NCL map outlines (faster)
    res@gsnMaximize           = True              ; Will maximize later
    res@tiMainString          = filename
    res@mpOutlineOn           = True
    res@mpDataBaseVersion     = "MediumRes"       ; default is "LowRes"
    res@mpOutlineBoundarySets = "AllBoundaries"   ; draw countries
  end if

  res@gsnLeftString   = v@long_name
  res@gsnCenterString = date(nt) + "  z=" + v&deptht(nd)

;---This will position data correctly on map.
  res@sfXArray     = lon2d
  res@sfYArray     = lat2d

  res@gsnAddCyclic = False      ; Data not global, don't add lon cyclic pt

;---Zoom in on map
  res@mpMinLatF    = min(lat2d)
  res@mpMaxLatF    = max(lat2d)
  res@mpMinLonF    = min(lon2d)
  res@mpMaxLonF    = max(lon2d)

  res@cnFillOn        = True          ; Turn on contour fill
  res@cnLinesOn       = False         ; Turn off contour lines
  res@cnLevelSpacingF = 0.5           ; Change contour level spacing

  res@mpFillOn               = True
  res@mpLandFillColor        = "tan"
  res@mpOceanFillColor       = "LightBlue"
  res@mpInlandWaterFillColor = "LightBlue"

  res@pmTickMarkDisplayMode    = "Always"  ; tickmarks with degree symbol

  res@pmLabelBarOrthogonalPosF = 0.1       ; move labelbar away from plot
  res@tiMainOffsetYF           = -0.03     ; move title towards plot

;---Create the plot (it won't get drawn yet)
  plot = gsn_csm_contour_map(wks,v(nt,nd,:,:),res)

;---Attach outlines from a shapefile of country outlines.
  if(USE_SHAPEFILE) then
    print("Attaching shapefile outlines. This can be slow...")
    countries_shp  = "countries_shp/countries.shp"

;---Set some resources for the shapefile outlines
    lnres                  = True
    lnres@gsLineThicknessF = 2.           ; default is 1

    lnres@minlat           = min(lat2d)   ; special resources to
    lnres@maxlat           = max(lat2d)   ; make the plotting
    lnres@minlon           = min(lon2d)   ; go faster
    lnres@maxlon           = max(lon2d)

;---Attach the outlines to the existing plot
    dum = gsn_add_shapefile_polylines(wks,plot,countries_shp,lnres)

;---This procedure maximizes the plot and draws it.
    pres = True
    maximize_output(wks,pres)
  end if 
end
