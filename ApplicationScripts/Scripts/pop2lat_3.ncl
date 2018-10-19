;************************************
; POP_Graphics: Cross-section after interpolating to lat/lon grid
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
;************************************
begin
;************************************
; read in data
;************************************
  pop   = addfile("CibmT31_gx3v4.pop.h.0001-06.nc","r")
  Tpop  = pop->TEMP               
;************************************
; popRemap: interpolate to 1x1 grid
;************************************ 
  T     = PopLatLon(Tpop,"gx3v4","1x1d","bilin","da","020604")
;************************************
; manipulate vertical coordinate
;************************************ 
  z_t           = pop->z_t
  z_t           = z_t*1.E-2       ; convert from cm to m
  z_t@long_name = "Depth (T grid)"; overwrite long name
  z_t@units     = "m"             ; fix units attribute
  
  T&z_t = z_t                     ; overwrite coord with modified z_t

; use lonPivot (in contributed.ncl) to reorder the longitudes so that no
; ocean basin is cut in half.  
  T     = lonPivot(T , 33.)       ; make data start near 33 degrees-east
;************************************
; create plot
;************************************
  wks = gsn_open_wks("ps","pop2lat") 
  gsn_define_colormap(wks,"gui_default")
  
  res                          = True       ; plot mods desired
  res@cnFillOn                 = True       ; turn on color fill
  res@cnLinesOn                = False      ; turn off contour lines
  res@cnLineLabelsOn           = False      ; turns off contour line labels
  res@cnInfoLabelOn            = False      ; turns off contour info label
  res@gsnSpreadColors          = True       ; use full colormap
  res@lbOrientation            = "vertical" ; vertical label bar
  res@trYReverse               = True       ; reverses y-axis

; we are going to adjust the label bar after the plot is drawn, so we set
; these resources, so we will only see the final product.
  res@gsnFrame                 = False      ; don't advance frame yet
  res@gsnDraw                  = False      ; don't draw yet
  
  latP  = -58
; create a nicely formated latitude label
  if (latP.gt.0.) then
    latP_label = sprintf("%0.1f", fabs(latP))+"N"
  else
    latP_label = sprintf("%0.1f", fabs(latP))+"S"
  end if
  
  res@tiMainString = "cross-section: "+latP_label ; add title
  plot = gsn_csm_contour(wks,T(0,:,{latP},:),res)  
;***************************************
;   adjust label bar
;***************************************
; Retrieve contour levels.
  getvalues plot
    "cnLevels" : levels
  end getvalues

  res@lbLabelStrings       = sprintf("%3.1f",levels)   ; Format the labels
  plot = gsn_csm_contour(wks,T(0,:,{latP},:),res)      ; redraw plot
  draw(wks)
  frame(wks)
end

