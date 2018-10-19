;----------------------------------------------------------------------
; newcolor_5.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Drawing partially transparent filled contours
;   - Using cnFillPalette to assign a color palette to contours
;   - Using more than 256 colors per frame
;----------------------------------------------------------------------
; Important note: in NCL V6.3.0 and earlier, there's a bug in which the
; colors in the labelbar do not correctly reflect the opacity applied
; to the filled contours.  This bug has been fixed in NCL V6.4.0.
; Set res@lbOverrideFillOpacity = True if you don't want the labelbar
; colors to have the opacity applied.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Function to generate dummy data with lat/lon coordinate arrays.
;----------------------------------------------------------------------
undef("dummy_data")
function dummy_data(data_rng[2],num_low,num_hgh,lat_rng[2],lon_rng[2],dims[2]:integer)
local iseed
begin
  iseed = toint(random_uniform(0,100,1))
  data  = generate_2d_array(num_low,num_hgh,data_rng(0),data_rng(1),iseed,dims)

;---Assign dummy coordinate arrays
  data!0   = "lat"
  data!1   = "lon"
  data&lat = fspan(lat_rng(0),lat_rng(1),dims(0))
  data&lon = fspan(lon_rng(0),lon_rng(1),dims(1))
  return(data)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Generate some dummy data with lat/lon coordinate arrays
  data1 = dummy_data((/998,1030/),5, 9,(/20,60/),(/-120,-60/),(/128,256/))
  data2 = dummy_data((/-0.0,0.4/),8,15,(/30,50/),(/-110,-80/),(/ 64,128/))

;---Start the graphics
  wks = gsn_open_wks("png","newcolor")  ; send graphics to PNG file

;---Set common resources for both plots
  res                     = True

  res@gsnDraw             = False       ; Don't draw plots or advance
  res@gsnFrame            = False       ; frame (need to overlay later)

  res@cnFillOn            = True        ; Turn on contour fill
  res@cnInfoLabelOn       = False       ; Turn off info label
  res@cnLineLabelsOn      = False       ; Turn off line labels

;---Resource for both plots
  res1 = res
  res2 = res

;---Contour resources specific to first (base) plot
  res1@cnLevelSelectionMode = "ManualLevels"
  res1@cnMinLevelValF       = 1000
  res1@cnMaxLevelValF       = 1027
  res1@cnLevelSpacingF      = 3
  res1@cnLinesOn            = False

  res1@lbOrientation        = "Horizontal"

;---Contour resources specific to second (overlay) plot
  res2@cnLevelSelectionMode = "ManualLevels"
  res2@cnMinLevelValF       = 0.05
  res2@cnMaxLevelValF       = 0.3
  res2@cnLevelSpacingF      = 0.05

  res2@cnLinesOn            = False
  res2@lbOrientation        = "Vertical"

;---Span the colors in the first color map
  res1@cnFillPalette = "BlueRed"

;---Create three copies of the base plot
  base_plot1 = gsn_csm_contour(wks,data1,res1)
  base_plot2 = gsn_csm_contour(wks,data1,res1)
  base_plot3 = gsn_csm_contour(wks,data1,res1)

;---Span the colors in the second color map
  res2@cnFillPalette = "GreenYellow"

;---Create fully opaque plot
  res2@tiMainString   = "Both plots fully opaque"
  opaque_plot1 = gsn_csm_contour(wks,data2,res2)

;---Create mostly opaque plot
  res2@tiMainString = "GreenYellow plot partially transparent"
  res2@cnFillOpacityF = 0.7
  opaque_plot2 = gsn_csm_contour(wks,data2,res2)

;---Create mostly transparent plot
  res2@cnFillOpacityF = 0.4
  res2@tiMainString = "GreenYellow plot mostly transparent"
  opaque_plot3 = gsn_csm_contour(wks,data2,res2)

;---Overlay various levels of opaque plots on base plots
  overlay(base_plot1,opaque_plot1)
  overlay(base_plot2,opaque_plot2)
  overlay(base_plot3,opaque_plot3)

;---Now draw everything and advance the frame (page)
  draw(base_plot1)
  frame(wks)

  draw(base_plot2)
  frame(wks)

  draw(base_plot3)
  frame(wks)
end
