;*************************************************
; panel_28.ncl
;
; Concepts illustrated:
;   - Drawing 10x6 plots in one panel
;   - Using special panel resources to draw plots closer together
;   - Generating dummy data
;   - Adding a common labelbar to paneled plots
;   - Reversing a color map
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin

;---Generate some dummy lat/lon data
  nlat      =  8
  nlon      = 16
  minlat    = 35
  maxlat    = 57
  minlon    = 41
  maxlon    = 82

  lat       = fspan(minlat,maxlat,nlat)
  lon       = fspan(minlon,maxlon,nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"

;---Array to hold dummy data values
  nrows = 10
  ncols =  6
  data4d = random_uniform(-6.5,6.5,(/nrows,ncols,nlat,nlon/))

  data4d!0   = "rows"
  data4d!1   = "cols"
  data4d!2   = "lat"
  data4d!3   = "lon"
  data4d&lat = lat
  data4d&lon = lon

  wks  = gsn_open_wks("png","panel")  ; send graphics to PNG file
  cmap = read_colormap_file("BlueYellowRed")

  res                        = True

  res@gsnDraw                = False
  res@gsnFrame               = False

  res@gsnAddCyclic           = False

  res@mpOutlineOn            = True
  res@mpPerimOn              = False
  res@mpMinLatF              = minlat
  res@mpMaxLatF              = maxlat
  res@mpMinLonF              = minlon
  res@mpMaxLonF              = maxlon
  
  res@lbLabelBarOn           = False

  res@cnFillOn               = True
  res@cnFillMode             = "RasterFill"
  res@cnFillPalette          = cmap(::-1,:)   ; reverse the color map
  res@cnLinesOn              = False
  res@cnLineLabelsOn         = False

  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnMinLevelValF         = -6
  res@cnMaxLevelValF         = 6
  res@cnLevelSpacingF        = 1


  res@tmXBLabelsOn         = False              ; no bottom labels
  res@tmXBOn               = False              ; no bottom tickmarks
  res@tmYRLabelsOn         = False              ; no right labels
  res@tmYROn               = False              ; no right tickmarks
  res@tmYLLabelsOn         = False              ; do not draw left labels
  res@tmYLOn               = False              ; no left tickmarks
  res@tmXTLabelsOn         = False              ; do not draw top labels
  res@tmXTOn               = False              ; no top tickmarks

  res@tmXBLabelFontHeightF = 0.035
  res@tmYLLabelFontHeightF = 0.035

  plots  = new(nrows*ncols,graphic)

;---Loop through rows and columns and generate each plot.
  i = 0
  do ir=0,nrows-1
    do ic=0,ncols-1
;--Turn off various tickmarks and labels depend on which plot this is
      if (i .le. 5) then
        res@tmXTLabelsOn = True            
        res@tmXTOn       = True
      else
        res@tmXTLabelsOn = False           
        res@tmXTOn       = False
      end if

      if (i .ge. 54) then
        res@tmXBLabelsOn = True            
        res@tmXBOn       = True            
      else
        res@tmXBLabelsOn = False           
        res@tmXBOn       = False
      end if

      if (i%6 .eq. 0) then
        res@tmYLLabelsOn = True
        res@tmYLOn       = True
      else
        res@tmYLLabelsOn = False
        res@tmYLOn       = False
      end if

      if (i%6 .eq. 5) then
        res@tmYRLabelsOn = True
        res@tmYROn       = True
      else
        res@tmYRLabelsOn = False
        res@tmYROn       = False
      end if

      plots(i) = gsn_csm_contour_map(wks,data4d(ir,ic,:,:),res)

      i = i+1
    end do
  end do

;---Create resources for paneling

  resP                            = True
  resP@gsnMaximize                = True    
  resP@gsnPanelLabelBar           = True    
  resP@gsnPanelMainFontHeightF    = .20
  resP@lbLabelFontHeightF         = 0.012
  resP@pmLabelBarWidthF           = 0.80
  resP@pmLabelBarHeightF          = 0.04

;---Scale plots based on one of the smaller plots, and not the first one.
  resP@gsnPanelScalePlotIndex     = 7

;---Add some extra space between plots since they are too close together
  resP@gsnPanelXWhiteSpacePercent = 2
  resP@gsnPanelYWhiteSpacePercent = 3

;---Leave some room for the leftmost and rightmost tickmark labels.
  resP@gsnPanelLeft               = 0.1
  resP@gsnPanelRight              = 0.9

;---Panel the plot.
  gsn_panel(wks,plots,(/nrows,ncols/),resP)
end
