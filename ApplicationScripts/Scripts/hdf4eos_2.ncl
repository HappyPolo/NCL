;*********************************
; hdf4eos_2.ncl
;
; Concepts illustrated:
;   - Plotting EOS-DIS data
;   - Reading HDF4 data
;   - Creating a radiance plot
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
;*********************************
begin 
;*********************************
; read in HDF file
;*********************************
 f = addfile("eos.hdf","r")
;*************************************************************
; read in tenth channel in EV_1KM_Emissive SDS
;*************************************************************
  ch10 = f->EV_1KM_Emissive(10,:,:)
  ch10_rad = ch10 * ch10@radiance_scales(10)
;*************************************************************
; assign named dimensions
;*************************************************************
  ch10_rad@long_name = "IR RADIANCE (12 um)"
;*************************************************************
; create plot
;*************************************************************
   wks = gsn_open_wks("png", "hdf4eos")      ; send graphics to PNG file
   cmap = read_colormap_file("gsltod")       ; read color map

   res = True
   res@cnFillOn         = True               ; color Fill 
   res@cnFillPalette    = cmap(:23,:)        ; set color map
   res@cnFillMode       = "RasterFill"       ; Raster Mode
   res@cnLinesOn        = False              ; Turn off contour lines

   res@lbLabelStride       = 2               ; every other label bar label
   res@lbOrientation       = "Vertical"      ; vertical label bar

   res@tiMainString        = "EOSDIS file"   ; title
   res@tiXAxisString       = "pixel"         ; x-axis title
   res@tiYAxisString       = "scanline"      ; y-axis title

   plot = gsn_csm_contour(wks,ch10_rad, res) ; create plot

end
