;******************************************************************
; hdf4eos_4.ncl
;
; Concepts illustrated:
;   - Plotting EOS-DIS data
;   - Reading HDF4 data
;   - Drawing grayscale filled contours
;   - Drawing raster contours
;   - Spanning part of a color map for contour fill
;   - Making the labelbar be vertical
;   - Adding titles to the X/Y axes
;   - Adding attributes to a variable
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Setting contour levels using a min/max contour level and a spacing
;   - Changing the center longitude for a cylindrical equidistant projection
;   - Drawing a map using the medium resolution map outlines
;   - Turning off the addition of a longitude cyclic point
;
;******************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*********************************
begin 
;*********************************
; read in HDF file
;*********************************
  f = addfile("eos.hdf","r")
;*************************************************************
; read in first channel in EV_250_Aggr1km_RefSB (0.65 um)
;*************************************************************
  ch1_int  = f->EV_250_Aggr1km_RefSB(0,2::5,2::5)
; orig is integer, make float
  ch1      = ch1_int*ch1_int@reflectance_scales(0) 

  lat2d    = f->Latitude
  lon2d    = f->Longitude

  ch1@lon2d  = lon2d
  ch1@lat2d  = lat2d
;*************************************************************
; assign named dimensions
;*************************************************************
  ch1@long_name = "VISIBLE REFLECTANCE (0.6 um)"
  ch1@units     = "unitless" 
;*************************************************************
; create plot
;*************************************************************
  wks = gsn_open_wks("png", "hdf4eos")      ; send graphics to PNG file 
  cmap = read_colormap_file("gsdtol")       ; read color map
  
  res                  = True
  res@cnFillOn         = True               ; color Fill 
  res@cnFillPalette    = cmap(9:30,:)       ; set color map
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        = False              ; Turn off contour lines
  
  res@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF   =  0.0               ; set min contour level
  res@cnMaxLevelValF   =  1.0               ; set max contour level
  res@cnLevelSpacingF  =  0.04              ; set contour spacing
  
  res@lbLabelStride       = 3               ; every third label bar label
  
  
  res@mpMinLatF           = min(lat2d)-5      ; choose map limits
  res@mpMaxLatF           = max(lat2d)+5
  res@mpMinLonF           = min(lon2d)-5
  res@mpMaxLonF           = max(lon2d)+5
  
  res@mpCenterLonF        = 180             ; change map center
  res@mpDataBaseVersion   = "MediumRes"      ; higher res coastline
  res@gsnAddCyclic        = False           ; needed b/c data not global
  
  res@tiMainString        = "eos-dis data on a ce projection"
  
  plot = gsn_csm_contour_map(wks,ch1, res) ; create plot
  
end



