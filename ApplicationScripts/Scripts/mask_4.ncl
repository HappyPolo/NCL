;*************************************************
; mask_4.ncl
;
; Concepts illustrated:
;   - Generating dummy data using "generate_2d_array"
;   - Drawing filled contours over Africa on an orthographic map
;   - Changing the view of an orthographic map
;   - Creating a color map using RGB triplets
;   - Centering the labels under the labelbar boxes
;   - Using "mask" to set a range of values in your data to missing
;   - Using map resources to specifically indicate which geographical areas to fill or mask
;   - Drawing a lat/lon grid over the ocean only
;   - Customizing a labelbar for a contour plot
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;************************************************
; Generate an ny x nx array of random data with a minimum
; of -10 and a maximum of 110.
;************************************************
  nx = 40
  ny = 40
  z  = generate_2d_array(15,15,-10.,110.,0,(/ny,nx/))
;************************************************
; Generate 1D lat/lon coord arrays and attach to data. Make sure
; to include the units so we don't get warning messages from the
; gsn_csm_contour_map routine.
;************************************************
  lat   = fspan(-35,38,ny)
  lon   = fspan(-18,52,nx)
  z!0   = "lat"
  z!1   = "lon"
  z&lat = lat
  z&lon = lon
  z&lat@units = "degrees_north"
  z&lon@units = "degrees_east"

;************************************************
; Indicate which geographic areas you want to fill, and
; then indicate which geographic areas you want to mask.
;************************************************
  fill_specs = (/"water","land"/)

  mask_specs = (/\
  "algeria","angola","angola-exclave-called-cabinda","benin","botswana",\
  "burundi","cameroon","central-african-republic","chad","congo","djibouti",\
  "egypt","equatorial-guinea","ethiopia","gabon","gambia","ghana","guinea",\
  "guinea-bissau","ivory-coast","kenya","lesotho","liberia","libya",\
  "madagascar","malawi","mali","mauritania","mauritius","morocco",\
  "mozambique","namibia","niger","nigeria","rwanda","senegal","sierra-leone",\
  "somalia","south-africa","sudan","swaziland","tanzania","togo","tunisia",\
  "uganda","upper-volta","western-sahara","zaire","zambia","zimbabwe"/)


;************************************************
; Open workstation and define colormap.
;************************************************
  wks = gsn_open_wks("png","mask")  ; send graphics to PNG file

  color_map = (/(/1.00,1.00,1.00/),(/0.00,0.00,0.00/),(/0.70,0.70,0.70/), \
                (/0.75,0.50,1.00/),(/0.50,0.00,1.00/),(/0.00,0.00,1.00/), \
                (/0.00,0.50,1.00/),(/0.00,1.00,1.00/),(/0.00,1.00,0.60/), \
                (/0.00,1.00,0.00/),(/0.70,1.00,0.00/),(/1.00,1.00,0.00/), \
                (/1.00,0.75,0.00/),(/1.00,0.38,0.38/),(/1.00,0.00,0.38/), \
                (/1.00,0.00,0.00/)/)

  gsn_define_colormap(wks,color_map)

;************************************************
; Set some resources.
;************************************************
  res                 = True
  res@gsnMaximize     = True
  res@gsnAddCyclic    = False

;************************************************
; Set some contour resources.
;************************************************
  res@cnFillOn        = True
  res@cnFillColors    = (/3,4,5,6,8,9,10,11,12,13,14,15/)
  res@cnFillDrawOrder = "Predraw"
  res@cnLineDrawOrder = "Predraw"

;************************************************
; Set some map projection resources.
;************************************************
  res@mpProjection         = "Orthographic"
  res@mpEllipticalBoundary = True
  res@mpCenterLatF         = 20.0
  res@mpCenterLonF         = 14.0

;************************************************
; Set some map lat/lon grid resources.
;************************************************
  res@mpGridAndLimbOn      = True
  res@mpGridSpacingF       = 10
  res@mpGridLineColor      = 2
  res@mpGridLineThicknessF = 1.1
  res@mpGridMaskMode       = "MaskLand"  ; Don't draw grid over land.

;************************************************
; Turn off the fill boundaries, since we are going
; to explicitly set which boundaries we want to
; fill.
;************************************************
  res@mpFillBoundarySets    = "NoBoundaries"
  res@mpFillAreaSpecifiers  = fill_specs
  res@mpSpecifiedFillColors = (/7,2/)

;************************************************
; Turn on masking, and set resource indicating
; areas to mask.
;************************************************
  res@mpAreaMaskingOn       = 1
  res@mpMaskAreaSpecifiers  = mask_specs

;************************************************
; Set some labelbar resources. Note that this labelbar
; has two more boxes than we have contour levels. These
; extra boxes are used to show the colors for land and ocean.
;************************************************
  res@lbOrientation    = "Vertical"
  res@lbBoxCount       = 14
  res@lbLabelFont      = "Helvetica-bold"
  res@lbLabelAlignment = "BoxCenters"
  res@lbLabelStrings   = (/"Ocean","Land","< 0","0-10","10-20","20-30", \
                           "30-40","40-50","50-60","60-70","70-80",     \
                           "80-90","90-100","> 100"/)
  res@lbFillColors     = (/7,2,3,4,5,6,8,9,10,11,12,13,14,15/)

;************************************************
; Create contours over a map.
;************************************************
  contour = gsn_csm_contour_map(wks,z,res)

end

