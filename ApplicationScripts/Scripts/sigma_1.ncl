;************************************
; sigma_1.ncl
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************
begin
;************************************
; open netcdf file and read in data
; this dataset is a 2D shelf model with the 
; y-axis being distance in m from the bottom 
; of the shelf to the surface, and the
; x-axis being distance along the shelf
;***********************************
 in  = addfile("./shelf_grid.nc","r")
 y   = in->y                          ; dimensioned (dist,sigma)
 d   = in->DENSITY
;************************************
; create new depth array
; we will interpolate the sigma coords 
; to these values
;***********************************
 depth         = new(120,"float")
 depth(0:19)   = ispan(0,99,5)
 depth(20:119) = ispan(100,199,1)
;************************************
; interpolate y (sigma) to depth
; arguments (sigma values for column,data values for column,
;***********************************
 nosigma = new((/4000,dimsizes(depth)/),"float")
; because each column has a unique set of coordinates, we
; must interpolate them individually. The total number of
; interpolations here (4000) slows the execution down a bit.

 nosigma             = linint1(y,d,False,depth,0)
 nosigma!0           = "dist"
 nosigma!1           = "depth"
 nosigma_s           = nosigma(depth|:,dist|:)
 nosigma_s@long_name = d@long_name     ; long_name used auto by plot template
;************************************
; create plot
;***********************************
 wks = gsn_open_wks("ps","sigma")       ; open a ps file
 gsn_define_colormap(wks,"gui_default") ; choose colormap

 res                      = True       ; plot mods desired

 res@cnFillOn             = True       ; turn on color fill
 res@cnLinesOn            = False      ; turn off contour lines
 res@gsnSpreadColors      = True       ; use full colormap
 res@lbOrientation        = "vertical" ; vertical label bar

 res@sfXArray             = y&dist     ; x axis array
 res@sfYArray             = depth      ; y axis array

 res@tiYAxisString        = "Dist from bottom to surface (m)"
 res@tiXAxisString        = "Dist from origin (km)"

 res@tiMainString              = "Data now in regular coordinates"

 plot = gsn_csm_contour(wks,nosigma_s,res)     ; create plot
;************************************
end
