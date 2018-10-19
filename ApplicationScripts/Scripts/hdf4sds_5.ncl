;*********************************
; hdf4sds_5.ncl
;
; Concepts illustrated:
;   - Reading multiple files with data from MODIS satellite
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Applying scale and offset attributes to data
;   - Converting "string" time values using cd_calendar
;   - Overlaying four sets of contours on a map
;   - Drawing raster contours
;   - Smoothing raster contours
;   - Changing the view of an orthographic map
;   - Drawing a map using the medium resolution map outlines
;   - Using "getvalues" to retrieve resource values
;
;*********************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*********************************
begin 
;*********************************
; Read in four MODIS HDF files
;*********************************
  f = addfile("MOD06_L2.A2007308.1530.005.2007309160423.hdf","r")
  g = addfile("MOD06_L2.A2007308.1710.005.2007309161404.hdf","r")
  h = addfile("MOD06_L2.A2007308.1845.005.2007309174451.hdf","r")
  j = addfile("MOD06_L2.A2007308.1535.005.2007309160306.hdf","r")

;*************************************************************
; Read in cloud temperature
;*************************************************************
  wv1s = f->Cloud_Top_Temperature
  wv2s = g->Cloud_Top_Temperature
  wv3s = h->Cloud_Top_Temperature
  wv4s = j->Cloud_Top_Temperature

; Apply scale and offset and convert to double
  wv1 =  wv1s@scale_factor*1.d * (wv1s - wv1s@add_offset)
  wv2 =  wv2s@scale_factor*1.d * (wv2s - wv2s@add_offset)
  wv3 =  wv3s@scale_factor*1.d * (wv3s - wv3s@add_offset)
  wv4 =  wv4s@scale_factor*1.d * (wv4s - wv4s@add_offset)

  time = doubletoint(f->Scan_Start_Time(0,0))

  gdate  = cd_inv_calendar(1993,1,1,0,0,time(0),"years since 1993-01-01",0)
  date2d = cd_calendar(gdate,0)
  date   = date2d(0,:) 

  lat2d1    = f->Latitude
  lon2d1    = f->Longitude
  lat2d2    = g->Latitude
  lon2d2    = g->Longitude
  lat2d3    = h->Latitude
  lon2d3    = h->Longitude
  lat2d4    = j->Latitude
  lon2d4    = j->Longitude

;*************************************************************
; Start the graphics
;*************************************************************
  wks = gsn_open_wks("png", "hdf4sds")            ; send graphics to PNG file
  cmap = read_colormap_file("rainbow")            ; read color data

;*************************************************************
; Set some resources that will apply to the base
; contour/map plot that we are going to use to
; overlay the other contour plots on.
;*************************************************************
  res                      = True

  res@gsnMaximize          = True                ; maximize pot in frame
  res@gsnFrame             = False               ; don't advance frame
  res@gsnDraw              = False               ; don't draw plot


  res@cnFillOn             = True               ; color Fill 
  res@cnFillPalette        = cmap(3:,:)         ; set color map
  res@cnFillMode           = "CellFill"         ; Raster Mode
  res@cnRasterSmoothingOn  = True
  res@cnRasterMinCellSizeF = 0.0005
  res@cnLinesOn            = False              ; Turn off contour lines
  res@cnLineLabelsOn       = False              ; Turn off contour lines
  res@cnMaxLevelCount      = 100


  res@trGridType                   = "TriangularMesh"

  res@gsnAddCyclic                 = False    ; Data is not cyclic

;******************************************************************
; Make a copy of the resources at this point, because these are 
; the resources we want to apply to the rest of the contour plots
; we're going to create later.
;******************************************************************
  res1 = res

;******************************************************************
; Set the rest of the resources that we only want to apply to
; the base map/contour plot.
;
;******************************************************************
  res@lbTitleString        = wv1s@long_name
  res@lbTitleFontHeightF   = 0.015               ; Make font smaller
  res@lbLabelFontHeightF   = 0.012               ; Make labels bigger
  res@lbTitleOffsetF       = -0.3
  res@lbBoxLinesOn         = False

  res@mpDataBaseVersion   = "MediumRes"          ; Higher res coastline
  res@mpProjection        = "Orthographic"

; Set limits of map, based on the min/max of all four datasets.
  res@mpLimitMode         = "LatLon"
  res@mpMinLatF           = min((/lat2d1,lat2d2,lat2d3,lat2d4/)) 
  res@mpMaxLatF           = max((/lat2d1,lat2d2,lat2d3,lat2d4/))
  res@mpMinLonF           = min((/lon2d1,lon2d2,lon2d3,lon2d4/))
  res@mpMaxLonF           = max((/lon2d1,lon2d3,lon2d3,lon2d4/))

  res@mpGridAndLimbOn     = True
  res@mpCenterLonF        = -90         ; change map center
  res@mpCenterLatF        =  40

  res@pmTickMarkDisplayMode        = "Always"
  
  res@tiMainString                 = "Four MODIS swaths : " + date(0) + "/" + \
                                     date(1) + "/" + date(2) + "  " + \
                                     date(3) + ":" + date(4) + " - 18:45"

  res@sfXArray             = lon2d1
  res@sfYArray             = lat2d1

;*************************************************************
; Create map/contour plot but don't draw it yet.
;*************************************************************
  plot = gsn_csm_contour_map(wks,wv1, res)

;*************************************************************
; Retrieve the contour levels used so we can set these for
; the remaining plots. We could have also set the contour
; levels above.
;*************************************************************
  getvalues plot@contour
    "cnMinLevelValF"  : minlevel
    "cnMaxLevelValF"  : maxlevel
    "cnLevelSpacingF" : levelspacing
  end getvalues  

  res1                      = True
  res1@cnLevelSelectionMode = "ManualLevels" ; Set manual contour levels
  res1@cnMinLevelValF       = minlevel
  res1@cnMaxLevelValF       = maxlevel
  res1@cnLevelSpacingF      = levelspacing
  res1@cnInfoLabelOn        = False
  res1@lbLabelBarOn         = False         ; Turn off b/c we already
                                            ; have one.
;*************************************************************
; Each new contour plot that we create we need to set
; the new 2D lat/lon arrays that correspond to this 
; dataset.
;*************************************************************
  res1@sfXArray             = lon2d2
  res1@sfYArray             = lat2d2

  plot2 = gsn_csm_contour(wks,wv2,res1)

  res1@sfXArray             = lon2d3
  res1@sfYArray             = lat2d3
  plot3 = gsn_csm_contour(wks,wv3,res1)

  res1@sfXArray             = lon2d4
  res1@sfYArray             = lat2d4
  plot4 = gsn_csm_contour(wks,wv4,res1)

;*************************************************************
; Overlay the 3 contour plots on the base map/contour plot.
; This works because we've set the sf*Array resources for each
; plot.
;*************************************************************

  overlay(plot,plot2)
  overlay(plot,plot3)
  overlay(plot,plot4)

;*************************************************************
; Drawing the base plot will cause all the overlaid plots 
; to be drawn as well.
;*************************************************************
  draw(plot)
  frame(wks)
end
