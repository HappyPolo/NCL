;*************************************************
; newcolor_14.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Using three different colormaps on one page
;   - Using cnFillPalette to assign a color palette to contours
;   - Drawing three sets of panels on one page with no margins
;   - Generating dummy data
;   - Adding a common labelbar to paneled plots
;   - Drawing the Aitoff map projection
;   - Adding figure strings to paneled plots
;   - Customizing figure strings in paneled plots
;   - Retrieving the bounding box of paneled objects
;*************************************************
; This example produces an identical plot to panel_26.ncl,
; except it uses the new "cnFillPalette" resource to
; set the colors used for each set of plots, and hence
; you can panel them without having to change the color map
; for each one.
;
; This example will only work with NCL V6.1.0 and later.
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin

;---Generate some dummy lat/lon data
  nlat      =  64
  nlon      = 128
  lat       = fspan(-90,90,nlat)
  lon       = fspan(-178.5,178.5,nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"

;---Array to hold dummy data values
  dmins = (/-20.,-10.,-21./)     ; Data min and max
  dmaxs = (/ 16., 10., 17./)
  dspas = (/  4.,  1.,  3./)

  data     = new((/nlat,nlon/),float)
  data!0   = "lat"
  data!1   = "lon"
  data&lat = lat
  data&lon = lon

  wks  = gsn_open_wks("png","newcolor") ; send graphics to PNG file

  res                        = True

  res@gsnDraw                = False
  res@gsnFrame               = False

  res@mpProjection           = "Aitoff"
  res@mpOutlineOn            = True
  res@mpPerimOn              = False
  res@lbLabelBarOn           = False

  res@cnLinesOn              = False
  res@cnFillOn               = True

  res@cnLevelSelectionMode   = "ManualLevels"

;---Create "nplots" dummy plots.
  nplots = 9
  plots  = new(nplots,graphic)

  colormaps = (/"wgne15","StepSeq25","BlueDarkRed18"/)
  do n=0,nplots-1
    dmin = dmins(n/3)
    dmax = dmaxs(n/3)
    dspa = dspas(n/3)

;---This is a new resource added in NCL V6.1.0
    res@cnFillPalette          = colormaps(n/3)

    res@cnMinLevelValF         = dmin
    res@cnMaxLevelValF         = dmax
    res@cnLevelSpacingF        = dspa

    mstart = toint(random_uniform(10,25,1))
    mend   = toint(random_uniform(10,25,1))
    xstart = random_uniform(dmin,dmin+2,1)
    xend   = random_uniform(dmax-2,dmax,1)
    data   = generate_2d_array(mstart, mend, xstart,xend, 0, (/nlat,nlon/))

    plots(n) = gsn_csm_contour_map(wks,data,res)
  end do

  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnFrame         = False
  pres@gsnPanelLabelBar = True
  pres@pmLabelBarWidthF = 0.8

;
; Panel the first set of plots without drawing them, so we
; can retrieve the bounding boxes and calculate the height.
;
  pres@gsnDraw = False
;
; "gsn_panel_return" is an unadvertised function. It behaves
; the same as "gsn_panel", except it returns all the objects 
; being paneled, including the labelbar if there is one.
;
  pplots = gsn_panel_return(wks,plots(0:2),(/1,3/),pres)

;
; Retrieve bounding boxes of all objects created by gsn_panel call.
;
; max(bb(:,0)) is the topmost location of all combined objects,
; and min(bb(:,1)) is the bottommost.
;
  bb     = NhlGetBB(pplots)
  height = max(bb(:,0)) - min(bb(:,1))

;---Using height value, now we can panel all sets of plots.
  pres@gsnDraw                          = True
  pres@gsnPanelTop                      = 0.9   ; leave room for title
  pres@gsnPanelBottom                   = pres@gsnPanelTop - height

;---figure string resources
  pres@gsnPanelFigureStringsPerimOn     = False
  pres@gsnPanelFigureStringsFontHeightF = 0.01
  pres@amJust                           = "TopLeft"

;---Main title, only on first set of plots
  pres@txString = "Multiple panels on one page, dummy data, 3 different colormaps"

  fig_strs = (/"a","b","c","d","e","f","g","h","i"/) + ")"
  do n=0,nplots-1,3
    pres@gsnPanelFigureStrings = fig_strs(n:n+2)
    gsn_panel(wks,plots(n:n+2),(/1,3/),pres)

;---Set for the next panel call.
    pres@txString = ""
    pres@gsnPanelTop    = pres@gsnPanelBottom
    pres@gsnPanelBottom = pres@gsnPanelTop-height
  end do
  frame(wks)
end
