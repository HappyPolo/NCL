;----------------------------------------------------------------------
; panel_37.ncl
;
; Concepts illustrated:
;   - Paneling twelve plots on a page with vertical labelbars
;   - Customizing a labelbar for a contour plot
;   - Generating dummy data
;   - Using cnFillPalette to assign a color palette to contours
;   - Formatting labelbar labels using "sprinti"
;   - Adding figure strings to paneled plots
;   - Using functions for cleaner code
;   - Forcing a tickmark label at beginning of X axis
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


;----------------------------------------------------------------------
; Function to generate dummy data with lat on Y axis and
; time on X axis.
;----------------------------------------------------------------------
undef("dummy_data")
function dummy_data(data_rng[2],lat,year,dims[*]:integer)
local iseed
begin
  iseed = toint(random_uniform(0,100,1))
  nlow  = toint(random_uniform(3,10,1))
  nhgh  = toint(random_uniform(7,10,1))
  data   = generate_2d_array(nlow,nhgh,data_rng(0),data_rng(1),\
                             iseed,dims)
;---Assign dummy coordinate arrays
  data!0  = "lat"
  data!1  = "time"

  data&lat   = lat
  data&time  = year
  data&lat@units  = "degrees_north"
  data&time@units = "year"
  return(data)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
;---Generate some dummy data with varying ranges
  year1   = ispan(1980,2005,1)
  year2   = ispan(2025,2050,1)
  year3   = ispan(2075,2100,1)
  lat     = ispan(300,410,5)/10.
  nlat    = dimsizes(lat)
  nyear   = dimsizes(year1)
  d1mnmx   = (/  -6, 6/)
  d2mnmx   = (/ -55, 5/)
  d3mnmx   = (/-220, 0/)
  d4mnmx   = (/  -1, 9/)

  data11 = dummy_data(d1mnmx,lat,year1,(/nlat,nyear/))
  data12 = dummy_data(d1mnmx,lat,year2,(/nlat,nyear/))
  data13 = dummy_data(d1mnmx,lat,year3,(/nlat,nyear/))
  data21 = dummy_data(d2mnmx,lat,year1,(/nlat,nyear/))
  data22 = dummy_data(d2mnmx,lat,year2,(/nlat,nyear/))
  data23 = dummy_data(d2mnmx,lat,year3,(/nlat,nyear/))
  data31 = dummy_data(d3mnmx,lat,year1,(/nlat,nyear/))
  data32 = dummy_data(d3mnmx,lat,year2,(/nlat,nyear/))
  data33 = dummy_data(d3mnmx,lat,year3,(/nlat,nyear/))
  data41 = dummy_data(d4mnmx,lat,year1,(/nlat,nyear/))
  data42 = dummy_data(d4mnmx,lat,year2,(/nlat,nyear/))
  data43 = dummy_data(d4mnmx,lat,year3,(/nlat,nyear/))

;---Set contour levels for all four plots
  levels1 = ispan(  -5, 5,  1)
  levels2 = ispan( -50, 0, 10)
  levels3 = ispan(-200, 0, 40)
  levels4 = ispan(   0, 8,  1)

;---Start the graphics
  wks = gsn_open_wks("png","panel")       ; send graphics to PNG file

;---Set common resources for all plots
  res                      = True
  res@gsnMaximize          = False        ; Maximize in frame
  res@gsnDraw              = False        ; Don't draw plots
  res@gsnFrame             = False        ; Don't advance frame
  res@cnFillOn             = True         ; Turn on contour fill
  res@cnInfoLabelOn        = False        ; Turn off info label
  res@cnLineLabelsOn       = False        ; Turn off line labels
  res@cnLinesOn            = False        ; Turn off contour lines
  res@cnLevelSelectionMode = "ExplicitLevels"

  res@tmYROn               = False
  res@tmXTOn               = False
  res@tmXBLabelAngleF      = 90.
  res@tmXBLabelJust        = "CenterLeft"

  res@lbLabelBarOn         = False        ; turn off labelbar, but still customize
  res@lbOrientation        = "Vertical"   ; it so we can recreate it later
  res@lbTitleAngleF        = 90.          ; title angle
  res@lbTitlePosition      = "Right"      ; title location
  res@lbTitleDirection     = "Across"     ; letter angle
  res@lbLabelFontHeightF   = 0.025
  res@tmXBMode             = "Manual"

;---Resources for 1st row of plots
  res1                = res
  res1@cnFillPalette  = "ncl_default"
  res1@cnLevels       = levels1
  res1@lbLabelStrings = sprinti("%-5i",levels1)
  res1@lbTitleString  = "Dummy data 1"

;---Resources for 2nd row of plots
  res2                = res
  res2@cnLevels       = levels2
  res2@cnFillPalette  = "gui_default"
  res2@lbLabelStrings = sprinti("%-5i",levels2)
  res2@lbTitleString  = "Dummy data 2"

;---Resources for 3rd row of plots
  res3                = res
  res3@cnLevels       = levels3
  res3@cnFillPalette  = "WhiteYellowOrangeRed"
  res3@lbLabelStrings = sprinti("%-5i",levels3)
  res3@lbTitleString  = "Dummy data 3"

;---Resources for 4th row of plots
  res4                = res
  res4@cnLevels       = levels4
  res4@cnFillPalette  = "precip2_17lev"
  res4@lbLabelStrings = sprinti("%-5i  ",levels4)
  res4@lbTitleString  = "Dummy data 4 with a longer title"

;---Contour resources for each set of contour plots
  res11               = res1
  res12               = res1
  res13               = res1
  res21               = res2
  res22               = res2
  res23               = res2
  res31               = res3
  res32               = res3
  res33               = res3
  res41               = res4
  res42               = res4
  res43               = res4

  plots = new(12,graphic)

;---Rightmost plots
  res13@lbLabelBarOn = True
  res23@lbLabelBarOn = True
  res33@lbLabelBarOn = True
  res43@lbLabelBarOn = True

;---Rightmost two plots
  res12@tmYLLabelsOn = False
  res13@tmYLLabelsOn = False
  res22@tmYLLabelsOn = False
  res23@tmYLLabelsOn = False
  res32@tmYLLabelsOn = False
  res33@tmYLLabelsOn = False
  res42@tmYLLabelsOn = False
  res43@tmYLLabelsOn = False

;---Left plots
  res11@tmXBTickStartF = min(year1)       ; make sure labeling starts at first timestep
  res21@tmXBTickStartF = min(year1)
  res31@tmXBTickStartF = min(year1)
  res31@tmXBTickStartF = min(year1)

;---Middle plots
  res12@tmXBTickStartF = min(year2)       ; make sure labeling starts at first timestep
  res22@tmXBTickStartF = min(year2)
  res32@tmXBTickStartF = min(year2)
  res42@tmXBTickStartF = min(year2)

;---Right plots
  res13@tmXBTickStartF = min(year3)       ; make sure labeling starts at first timestep
  res23@tmXBTickStartF = min(year3)
  res33@tmXBTickStartF = min(year3)
  res43@tmXBTickStartF = min(year3)


  plots(0)   = gsn_csm_contour(wks,data11,res11)
  plots(1)   = gsn_csm_contour(wks,data12,res12)
  plots(2)   = gsn_csm_contour(wks,data13,res13)
  plots(3)   = gsn_csm_contour(wks,data21,res21)
  plots(4)   = gsn_csm_contour(wks,data22,res22)
  plots(5)   = gsn_csm_contour(wks,data23,res23)
  plots(6)   = gsn_csm_contour(wks,data31,res31)
  plots(7)   = gsn_csm_contour(wks,data32,res32)
  plots(8)   = gsn_csm_contour(wks,data33,res33)
  plots(9)   = gsn_csm_contour(wks,data41,res41)
  plots(10)  = gsn_csm_contour(wks,data42,res42)
  plots(11)  = gsn_csm_contour(wks,data43,res43)
 
;---Panel the plots
  pres                        = True 
  pres@gsnMaximize            = True
  pres@gsnPanelFigureStrings  = (/"a","b","c","d","e","f","g","h","i","j","k","l"/) + ")"
  pres@gsnPanelMainString     = "4 x 3 panel plot with four vertical labelbars"

  gsn_panel(wks,plots,(/4,3/),pres)

end
