;*********************************
; hdf4eos_1.ncl
;
; Concepts illustrated:
;   - Plotting EOS-DIS data
;   - Reading HDF4 data
;   - Creating a reflectance plot
;   - Drawing grayscale filled contours
;   - Drawing raster contours
;   - Spanning part of a color map for contour fill
;   - Making the labelbar be vertical
;   - Adding titles to the X/Y axes
;
;*********************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*********************************
begin 
;*********************************
; read in HDF file
;*********************************
 f = addfile("eos.hdf","r")
; print(f)
;*************************************************************
; read in first channel in EV_250_Aggr1km_RefSB (0.65 um)
;*************************************************************
 ch1   = f->EV_250_Aggr1km_RefSB(0,::5,::5)
 ch1_float   = ch1*ch1@reflectance_scales(0) ; orig is integer, make float
;*************************************************************
; assign named dimensions
;*************************************************************
  ch1_float@long_name = "VISIBLE REFLECTANCE (0.6 um)"
  ch1_float@units     = "unitless" 
;*************************************************************
; create plot
;*************************************************************
   wks = gsn_open_wks("png", "hdf4eos")      ; send graphics to PNG file 
   cmap = read_colormap_file("gsdtol")       ; read color map

   res = True
   res@cnFillOn         = True               ; color fill 
   res@cnFillPalette    = cmap(9:30,:)       ; set color map
   res@cnFillMode       = "RasterFill"       ; raster mode
   res@cnLinesOn        = False              ; Turn off contour lines

   res@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
   res@cnMinLevelValF   =  0.0               ; set min contour level
   res@cnMaxLevelValF   =  1.0               ; set max contour level
   res@cnLevelSpacingF  =  0.04              ; set contour spacing

   res@lbLabelStride       = 2               ; every other label bar label
   res@lbOrientation       = "Vertical"      ; vertical label bar

   res@tiMainString        = "Sample from an EOS-DIS hdf file"
   res@tiXAxisString       = "pixel"
   res@tiYAxisString       = "scanline"

   plot = gsn_csm_contour(wks,ch1_float, res) ; create plot

end
