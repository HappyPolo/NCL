;***********************************************
; raster_1.ncl
;
; Concepts illustrated:
;   - Drawing raster contours over a map
;   - Turning off contour lines
;   - Explicitly setting the fill color for land
;   - Creating a color map using named colors
;   - Using draw order resources to make sure filled map areas are drawn last
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; open netCDF file
;************************************************
  a = addfile("cell.nc","r")
;************************************************
; Read in Regression Coef
;************************************************
  rcoef    = a->IB
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","raster")         ; send graphics to PNG file
  res                  = True                ; plot mods desired
;===================================
; you can have the contour lines on in raster mode, but their thickness
; actually make the plot look like is was contoured normally.

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        =  False             ; Turn off contour lines
;================================
; these three resources make the continents look nice. The first two
; make them color, and the later adds continental outlines when
; raster mode is used.

  res@cnLineDrawOrder  = "Predraw"          ; Draw lines and filled
  res@cnFillDrawOrder  = "Predraw"          ; areas before map gets set
;=================================
  res@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF   = -2.0               ; set min contour level
  res@cnMaxLevelValF   =  0.0               ; set max contour level
  res@cnLevelSpacingF  =  0.5               ; set contour spacing

  res@mpCenterLonF     = 180                ; set map center at 180
  res@mpLandFillColor  = "light yellow"     ; choose color of continents.
                                            ; must be in colormap  

  res@gsnCenterString  = "Nov 86-Sept 89"   ; add center string
  res@gsnRightString   = "cm/mb"            ; add right string

  res@cnFillPalette = (/"magenta","blue","orange","green","yellow","red"/) 

  plot = gsn_csm_contour_map_ce(wks,rcoef, res) ; create plot

end

