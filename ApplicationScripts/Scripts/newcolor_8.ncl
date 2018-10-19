;----------------------------------------------------------------------
; newcolor_8.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Drawing partially transparent filled vectors
;   - Overlaying filled vectors on filled contours
;   - Moving the vector reference annotation into the plot
;   - Making the vector reference annotation smaller
;   - Subscripting a color table for contour fill
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
; NOTE: The second frame of this example will only work with 
;       NCL V6.1.0 and later.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;---read in zonal winds
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)
  v = a->V(1,:,:)

  spd = sqrt(u^2+v^2)
  copy_VarMeta(u,spd)

;---Graphics
  wks  = gsn_open_wks("png","newcolor") ; send graphics to PNG file

  cnres                             = True
  cnres@gsnMaximize                 = True
  cnres@gsnDraw                     = False
  cnres@gsnFrame                    = False

  cmap = read_colormap_file("WhiteBlueGreenYellowRed")
  cnres@cnLinesOn                   = False
  cnres@cnFillOn                    = True
  cnres@cnFillPalette               = cmap(15:,:)
  cnres@mpFillOn                    = False
  cnres@mpGeophysicalLineColor      = "Grey18"
  cnres@mpGeophysicalLineThicknessF = 1.5
  cnres@gsnAddCyclic                = False

  vcres                         = True
  vcres@gsnDraw                 = False
  vcres@gsnFrame                = False

  vcres@vcFillArrowsOn          = True
  vcres@gsnRightString          = ""
  vcres@gsnLeftString           = ""
  vcres@vcRefMagnitudeF         = 30.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.02             ; define length of vec ref
  vcres@vcMinFracLengthF        = 0.3
  vcres@vcMinDistanceF          = 0.02
  vcres@vcRefAnnoOrthogonalPosF = -0.45
  vcres@vcRefAnnoFontHeightF    = 0.005

  cnres@tiMainString    = "Fully opaque filled vectors over filled contours"

;---Draw fully opaque vectors
  uv_plot  = gsn_csm_vector(wks,u,v,vcres)
  spd_plot = gsn_csm_contour_map(wks,spd,cnres)
  overlay(spd_plot,uv_plot)
  draw(spd_plot)
  frame(wks)

;---This time make vectors partially transparent
  vcres@vcGlyphOpacityF = 0.3
  cnres@tiMainString    = "Partially transparent vectors over filled contours"

  uv_plot  = gsn_csm_vector(wks,u,v,vcres)
  spd_plot = gsn_csm_contour_map(wks,spd,cnres)

  overlay(spd_plot,uv_plot)
  draw(spd_plot)
  frame(wks)

end


