;----------------------------------------------------------------------
; panel_38.ncl
;
; Concepts illustrated:
;   - Paneling twelve plots on a page as three different panels
;   - Controlling the position of plots in a panel
;   - Generating dummy data
;   - Using cnFillPalette to assign a color palette to contours
;   - Adding figure strings to paneled plots
;   - Using functions for cleaner code
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


;----------------------------------------------------------------------
; Function to generate dummy data.
;----------------------------------------------------------------------
undef("dummy_data")
function dummy_data(data_rng[2],lat[*]:numeric,lon[*]:numeric,narrays)
local iseed, dims, nlow, nhgh
begin
  nlat = dimsizes(lat)
  nlon = dimsizes(lon)
  dims = (/narrays,nlat,nlon/)
  data = new(dims,float)
;---Assign dummy coordinate arrays
  data!0  = "index" 
  data!1  = "lat"
  data!2  = "lon"

  data&index      = ispan(0,narrays-1,1)
  data&lat        = lat
  data&lon        = lon
  data&lat@units  = "degrees_north"
  data&lon@units  = "degrees_east"

  do n=0,narrays-1
    iseed = toint(random_uniform(0,100,1))
    nlow  = toint(random_uniform(3,10,1))
    nhgh  = toint(random_uniform(7,10,1))
    data(n,:,:)   = generate_2d_array(nlow,nhgh,data_rng(0),data_rng(1),\
                                      iseed,dims(1:))
  end do
  return(data)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
;---Map area we're interested in
  minlat  = -35
  maxlat  = -30
  minlon  = 114
  maxlon  = 119

;---Generate some dummy lat, lon, and data arrays
  lat     = fspan(minlat,maxlat,30)
  lon     = fspan(minlon,maxlon,30)
  nlat    = dimsizes(lat)
  nlon    = dimsizes(lon)
  d1mnmx  = (/35,385/)
  d2mnmx  = (/-105,105/)
  data1   = dummy_data(d1mnmx,lat,lon,8)
  data2   = dummy_data(d2mnmx,lat,lon,4)

;---Set contour levels for two sets of plots
  levels1 = ispan(40,380,20)
  levels2 = ispan(-100,100,10)

;---Start the graphics
  wtype          = "png"
  wtype@wkWidth  = 1000
  wtype@wkHeight = 1000
  wks = gsn_open_wks(wtype,"panel")       ; send graphics to PNG file


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
  res@lbLabelBarOn         = False
  res@gsnAddCyclic         = False

  res@tmXBOn               = False
  res@tmYLOn               = False
  res@tmXTOn               = False
  res@tmYROn               = False

  res@mpDataBaseVersion    = "MediumRes"
  res@mpFillOn             = True
  res@mpOceanFillColor     = "white"
  res@mpLandFillColor      = "transparent"
  res@mpFillDrawOrder      = "PostDraw"

  res@mpOutlineOn          = True
  res@mpPerimOn            = True
  res@mpMinLatF            = minlat
  res@mpMaxLatF            = maxlat
  res@mpMinLonF            = minlon
  res@mpMaxLonF            = maxlon

;---Resources for 1st 2 rows of plots
  res1                = res
  res1@cnFillPalette  = "BlGrYeOrReVi200"
  res1@cnLevels       = levels1

;---Resources for 3rd row of plots
  res2                = res
  res2@cnLevels       = levels2
  res2@cnFillPalette  = "precip4_diff_19lev"

  plots1 = new(8,graphic)
  plots2 = new(4,graphic)

;---Create two sets of plots
  do n=0,7
    plots1(n)   = gsn_csm_contour_map(wks,data1(n,:,:),res1)
  end do

  do n=0,3
    plots2(n)   = gsn_csm_contour_map(wks,data2(n,:,:),res2)
  end do

;---Get ready to panel plots
 
;---Specify y positions of each row of plots.
  ypos1  = 0.962     ; top row
  ypos2  = 0.667     ; middle row
  ypos3  = 0.317     ; bottom row
 
;---Make sure the title is the same distance for each
  dist_from_title_to_plot = 0.013
  ytitl1 = ypos1 + dist_from_title_to_plot
  ytitl2 = ypos2 + dist_from_title_to_plot
  ytitl3 = ypos3 + dist_from_title_to_plot

  nrows       = 3   
  plot_height = 1./tofloat(nrows)

  pres                          = True 
;  pres@gsnPanelDebug            = True      ; prints debug info
  pres@gsnFrame                 = False
  pres@gsnMaximize              = True
  pres@gsnPanelMainFontHeightF  = 0.015
  pres@gsnPanelFigureStrings    = (/"DJF","MAM","JJA","SON"/)
  pres@gsnPanelFigureStringsFontHeightF  = 0.01

;---Top row
  pres@gsnPanelTop              = 1.0                             ; Make sure each set of plots gets a 
  pres@gsnPanelBottom           = pres@gsnPanelTop - plot_height  ; third of the total height.
  pres@gsnPanelYF               = (/ypos1,ypos1,ypos1,ypos1/)     ; Y position of top of plots

  pres@gsnPanelMainString       = "Long title for the first row of plots"
  pres@gsnPanelMainPosYF        = ytitl1    ; Y position of title
  gsn_panel(wks,plots1(0:3),(/1,4/),pres)

;---Turn on labelbar for bottom two rows
  pres@gsnPanelLabelBar         = True
  pres@pmLabelBarHeightF        = 0.05
  pres@pmLabelBarOrthogonalPosF = -0.01
  pres@lbTitleString            = "(mm season~S~-1~N~)"
  pres@lbTitleFontHeightF       = 0.01
  pres@lbTitlePosition          = "Bottom"      ;position of label bar
  pres@lbLabelFontHeightF       = 0.01

;---Middle row
  pres@gsnPanelTop              = pres@gsnPanelBottom
  pres@gsnPanelBottom           = pres@gsnPanelTop - plot_height
  pres@gsnPanelYF               = (/ypos2,ypos2,ypos2,ypos2/)      ; Y position of top of plots

  pres@gsnPanelMainString       = "Long title for the second row of plots"
  pres@gsnPanelMainPosYF        = ytitl2    ; Y position of title
  gsn_panel(wks,plots1(4:7),(/1,4/),pres)
 
;---Bottom row
  pres@gsnPanelTop              = pres@gsnPanelBottom
  pres@gsnPanelBottom           = 0.0
  pres@gsnPanelYF               = (/ypos3,ypos3,ypos3,ypos3/)      ; Y position of top of plots

  pres@gsnPanelMainString       = "Long title for the third row of plots"
  pres@gsnPanelMainPosYF        = ytitl3    ; Y position of title
  gsn_panel(wks,plots2,(/1,4/),pres)

  frame(wks)
end
