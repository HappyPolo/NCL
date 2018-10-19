;----------------------------------------------------------------------
; shapefiles_8_panel.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using data from shapefiles to draw areas of interest in India
;   - Zooming in on India on a cylindrical equidistant map
;----------------------------------------------------------------------
; The shapefiles for India were obtained from the
; "Global Administratie Areas" website:
;
;      http://www.gadm.org/country
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  start_time = get_cpu_time()

  dir       = "./"
  filenames = systemfunc("ls -1 " + dir + "IND_adm*.shp")

  nfiles     = dimsizes(filenames)
  panel_dims = (/2,2/)      ; two rows, three columns

;--- Open workstation.
  wks = gsn_open_wks("png","shapefiles_panel") ; send graphics to PNG file

  res               = True
  res@gsnMaximize   = True
  res@gsnDraw       = False
  res@gsnFrame      = False

  res@mpFillOn      = False                ; Turn off map fill 
  res@mpOutlineOn   = False                ; Use outlines from shapefile
  res@pmTickMarkDisplayMode = "Always"     ; Turn on fancier tickmark labels.

;---Zoom in on area of interest
  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             =  5
  res@mpMaxLatF             = 37
  res@mpMinLonF             = 65
  res@mpMaxLonF             = 99
  res@tiMainFont            = "helvetica"    ; default is helvetica-bold
;
; Loop through the each shapefile, and attach the shapefile
; outlines to a different map everytime, with a different 
; color.
;
  colors = (/"Black","Purple","IndianRed","ForestGreen"/)

;---Resource list for shapefile outlines
  lnres = True

  map = new(nfiles,graphic)
  do i=0,nfiles-1
    res@tiMainString = filenames(i)

;---Create map.
    map(i) = gsn_csm_map(wks,res)

;---Attach polylines
    lnres@gsLineColor = colors(i) 
    dumstr            = unique_string("poly")
    map@$dumstr$ = gsn_add_shapefile_polylines(wks,map(i),filenames(i),lnres)
  end do

;---Draw all plots on one page
  pres             = True
  pres@gsnMaximize = True
  gsn_panel(wks,map,panel_dims,pres)

;---Calculate total elapsed time for this script.
  diff_time = get_cpu_time() - start_time
  print("=====> CPU Elapsed Time: " + diff_time + " seconds <=====")
end
