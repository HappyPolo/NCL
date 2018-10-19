;----------------------------------------------------------------------
;  mapoutlines_4.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Drawing outlines of Sweden and Norway from shapefiles
;----------------------------------------------------------------------
; The shapefiles for this example were obtained from the
; "Global Administrative Areas" website:
;
;      http://www.gadm.org/country
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;----------------------------------------------------------------------
; Read data
;----------------------------------------------------------------------
  minlon   =   4
  maxlon   =  25
  minlat   =  55
  maxlat   =  70
  filename = ncargpath("data") + "/cdf/uv300.nc"
  a        = addfile(filename,"r")
  u        = a->U(1,:,:)

  wks = gsn_open_wks("png","mapoutlines")    ; send graphics to PNG file

;----------------------------------------------------------------------
; Set some map resources
;----------------------------------------------------------------------
  res                       = True
  
  res@gsnMaximize           = True           ; maximize plot in frame
  res@gsnDraw               = False
  res@gsnFrame              = False

  res@cnFillOn              = True           ; turn on contour fill
  res@cnLinesOn             = False          ; turn off contour lines
  res@cnLineLabelsOn        = False          ; turn off contour labels
  res@lbLabelBarOn          = False          ; turn off labelbar

  res@mpFillDrawOrder       = "PostDraw"     ; draw map fill last

  res@gsnRightString        = ""             ; turn off special titles
  res@gsnLeftString         = ""

  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             = minlat
  res@mpMaxLatF             = maxlat 
  res@mpMinLonF             = minlon
  res@mpMaxLonF             = maxlon

  res@mpFillOn              = False
  res@mpOutlineOn           = False

  res@pmTickMarkDisplayMode = "Always"      ; tickmarks for some maps
  res@gsnAddCyclic          = False         ; don't add longitude cyclic point

  res@gsnCenterString       = "Outlines from shapefiles"

  plot = gsn_csm_contour_map(wks,u({minlat-2:maxlat+2},\
                                   {minlon-2:maxlon+3}),res)

;---Attach shapefile polylines to map 
  dir1       = "SWE_adm/"
  dir2       = "NOR_adm/"
  filename1  = "SWE_adm0.shp"
  filename2  = "NOR_adm0.shp"

  lnres                  = True
  lnres@gsLineThicknessF = 3.0

  poly1 = gsn_add_shapefile_polylines(wks,plot,dir1+filename1,lnres)
  poly2 = gsn_add_shapefile_polylines(wks,plot,dir2+filename2,lnres)
  draw(plot)
  frame(wks)

end
