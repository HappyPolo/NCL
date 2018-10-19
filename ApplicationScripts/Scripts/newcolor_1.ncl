;----------------------------------------------------------------------
; newcolor_1.ncl 
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
; The purpose of this example is to show the differences between the
; new and improved color model that was added in NCL Version 6.1.0,
; and the old color model.
;
; In the old model (NCL versions 6.0.0 and earlier), if you loaded
; a color map with no gray in it, then you wouldn't get gray-filled
; land (the default for gsn_csm_contour_map). You had to add gray
; to the color map yourself, which could be an issue if you already
; have a color map with 256 colors.
;
; In the new model, you are no longer limited to 256 colors. Also, 
; when you use a named color (as gsn_csm_contour_map does for the
; land fill), then you will get that color.
;
; In this example, if you run it with NCL V6.0.0 or earlier, you
; will get light-blue land, because this is the closest match NCL
; finds.
;
; With NCL V6.1.0, you get gray-filled land.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---read in zonal winds
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; July zonal winds

  wks  = gsn_open_wks("png","newcolor")  ; send graphics to PNG file

  res                 = True
  res@gsnMaximize     = True       ; maximize in frame
  res@cnLinesOn       = False
  res@cnFillOn        = True
  res@cnFillPalette   = "BlueYellowRed"   ; change the color palette

  res@mpFillDrawOrder = "PostDraw" ; Make sure land fill is drawn 
                                   ; on top of filled contours

  res@tiMainString    = "NCL version 6.1.x will give you gray land"

  plot = gsn_csm_contour_map(wks,u,res)
end
