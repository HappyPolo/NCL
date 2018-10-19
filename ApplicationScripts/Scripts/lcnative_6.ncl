;*******************************************************
; lcnative_6.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
begin
;************************************************
; open file and read in data
;************************************************
  fili  = "ruc2.bgrb.20020418.i12.f00.grb"
  f     = addfile (fili, "r")

  u     = f->U_GRD_252_HTGL
  vpt   = f->VPTMP_252_HYBL
  lat2d = f->gridlat_252  
  lon2d = f->gridlon_252  
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lcnative")      ; send graphics to PNG file

; to create a contour on contour plot that is also a native
; grid projection, requires that we create two plots. only the
; first plot will be on a map. the second will be a simple contour
; plot.

;*******************************************
; create first plot
;*******************************************
  res                          =  True              ; plot mods desired
  res@mpProjection             = "LambertConformal" ; choose projection
  res@mpLimitMode              = "Corners"          ; choose range of map
  res@mpLeftCornerLatF         = lat2d@corners(0)
  res@mpLeftCornerLonF         = lon2d@corners(0)
  res@mpRightCornerLatF        = lat2d@corners(2)
  res@mpRightCornerLonF        = lon2d@corners(2)
  res@mpLambertParallel1F      = lon2d@Latin1       ; ncl adds from grib file
  res@mpLambertParallel2F      = lon2d@Latin2       ; ncl adds from grib file
  res@mpLambertMeridianF       = lat2d@Lov          ; ncl adds from grib file
  res@pmTickMarkDisplayMode    = "Always"
  res@mpFillOn                 =  False             ; turn off map fill
  res@mpOutlineDrawOrder       = "PostDraw"         ; continent outline last
  res@mpOutlineBoundarySets    = "GeophysicalAndUSStates" ; state boundaries
  res@tfDoNDCOverlay           = True               ; don't transform
  res@gsnAddCyclic             = False              ; regional data 
  res@cnFillOn                 = True               ; turn on color
  res@cnLinesOn                = False              ; turn off contour lines
  res@cnFillPalette            = "gui_default"      ; set color map

  res@gsnDraw                  = False              ; don't draw yet
  res@gsnFrame                 = False              ; don't advance frame yet
  plot = gsn_csm_contour_map(wks,vpt(9,:,:),res)
;*******************************************
; create second contour only plot
; the trick here is to also turn off the transformation
; of the contour plot.
;*******************************************
  cnres                        = True
  cnres@tfDoNDCOverlay         = True               ; don't transform
  cnres@cnInfoLabelOn          = False              ; turn off info label
  cnres@cnLineLabelsOn         = False              ; turn off line labels
  cnres@tiMainString           = "Contour on Contour: Native Grid" ; title
  cnres@gsnDraw                = False              ; don't draw yet
  cnres@gsnFrame               = False              ; don't advance frame yet
  plotcn = gsn_contour(wks,u,cnres)

  overlay(plot,plotcn)
  draw(plot)
  frame(wks)

end
