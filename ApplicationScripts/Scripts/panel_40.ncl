;----------------------------------------------------------------------
; panel_40.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Attaching plots along the Y axis with a single labebar
;   - Generating dummy data using "generate_2d_array"
;   - Using gsn_panel to add a main title to a series of attached plots
;   - Turning off tickmarks and their labels
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

undef("generate_dummy_data")
function generate_dummy_data(pmin,pmax,dmin,dmax,minlat,maxlat,minlon,maxlon,nlat,nlon)
local lat, lon
begin
  data = generate_2d_array(pmin, pmax, dmin, dmax, 0, (/nlat,nlon/))
  lat = fspan(minlat,maxlat,nlat)
  lon = fspan(minlon,maxlon,nlon)
  lat!0 = "lat"
  lon!0 = "lon"
  lat@units = "degrees_north"
  lon@units = "degrees_east"

  data!0 = "lat"
  data!1 = "lon"
  data&lat = lat
  data&lon = lon
  return(data)
end
;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin 
;---Generate some dummy data over part of South America
  nlat   = 90
  nlon   = 180
  minlat = -60
  maxlat =  12
  minlon = -90
  maxlon = -60

  data1 = generate_dummy_data(10, 12, 270., 310.,minlat,maxlat,minlon,maxlon,nlat,nlon)
  data2 = generate_dummy_data( 9, 14, 290., 315.,minlat,maxlat,minlon,maxlon,nlat,nlon)
  data3 = generate_dummy_data(10, 13, 260., 309.,minlat,maxlat,minlon,maxlon,nlat,nlon)
  data4 = generate_dummy_data(12, 15, 275., 311.,minlat,maxlat,minlon,maxlon,nlat,nlon)

  wks = gsn_open_wks("png","panel")

;---Set up resources.
  res                     = True

  res@gsnMaximize          = True
  res@gsnDraw              = False
  res@gsnFrame             = False

  res@mpMinLatF            = minlat
  res@mpMaxLatF            = maxlat
  res@mpMinLonF            = minlon
  res@mpMaxLonF            = maxlon
  res@mpOceanFillColor     = "white"
  res@mpLandFillColor      = "transparent"
  res@mpFillDrawOrder      = "PostDraw"

; Set contour levels and turn on contour fill
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = ispan(260,305,5)
  res@cnFillOn              = True        
  res@cnFillPalette         = "WhiteBlueGreenYellowRed"

  res@cnLinesOn             = False
  res@cnLineLabelsOn        = False

  res@gsnAddCyclic          = False        ; don't add longitude cyclic point

  res@pmTickMarkDisplayMode = "Always"     ; nicer map tickmarks
  res@lbOrientation         = "vertical"

  res@gsnStringFontHeightF         = 0.02  ; make font smaller
  res@gsnLeftStringOrthogonalPosF  = 0.01  ; move strings down
  res@gsnRightStringOrthogonalPosF = 0.01
;
; For each plot, customize resources for the labelbar and/or tickmarks.
;
  res@lbLabelBarOn   = False
  res@tmYROn         = False
  res@tmXBOn         = False
  res@tmXTOn         = False
  res@gsnLeftString  = " Plot1"   ; Add space so titles don't run into each
  res@gsnRightString = "Date1 "   ; other after we attach plots along Y axes.
  plot1 = gsn_csm_contour_map(wks,data1,res)

  res@tmYLOn         = False
  res@gsnLeftString  = " Plot2"
  res@gsnRightString = "Date2 "
  plot2 = gsn_csm_contour_map(wks,data2,res) 

  res@gsnLeftString  = " Plot3"
  res@gsnRightString = "Date3 "
  plot3 = gsn_csm_contour_map(wks,data3,res)

  res@lbLabelBarOn   = True
  res@gsnLeftString  = " Plot4"
  res@gsnRightString = "Date4 "
  plot4 = gsn_csm_contour_map(wks,data4,res)

;---Attach the three right plots to the left plot along the Y axis.
  res1                     = True
  res2                     = True
  res1@gsnMaximize         = True
  res2@gsnAttachPlotsYAxis = True

  anno1 = gsn_attach_plots(plot1,(/plot2,plot3,plot4/),res1,res2)

  draw(plot1)
  frame(wks)

;---Panel these attach plots simply to add a title
  pres                    = True
  pres@gsnMaximize        = True

 ;Use these two resources with NCL V6.3.0 and earlier.
 ;pres@txString    = "Use gsn_panel 'trick' to add a common title"
 ;pres@txFont      =  "helvetica-bold"

 ;Use these two resources with NCL V6.4.0 and later. The tx* ones will still work.
  pres@gsnPanelMainString = "Use gsn_panel 'trick' to add a common title"
  pres@gsnPanelMainFont   = "helvetica-bold"

  gsn_panel(wks,plot1,(/1,1/),pres)
end
