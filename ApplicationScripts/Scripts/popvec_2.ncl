; =================================================;
; popvec_2.ncl
; =================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; =================================================;
begin
  f = addfile("b20.007.pop.h.1000-01.nc.nc","r")

  u           = f->UVEL
  v           = f->VVEL
  rot         = f->ANGLE

  urot        = u(0,0,:,:)
  vrot        = v(0,0,:,:)
  urot        = u(0,0,:,:)*cos(rot) - v(0,0,:,:)*sin(rot)  
  vrot        = u(0,0,:,:)*sin(rot) + v(0,0,:,:)*cos(rot) 

  lat2d       = f->ULAT
  lon2d       = f->ULONG
;===================================================;
; note, if you are going to sub sample the grid in the plot call below,
; you must also subsample it here!
;===================================================;
  urot@lon2d  = lon2d
  urot@lat2d  = lat2d
  vrot@lon2d  = lon2d
  vrot@lat2d  = lat2d
; =================================================;
; create plots
; =================================================;
  wks  = gsn_open_wks("ps","popvec")            ; open a ps file
  gsn_define_colormap(wks,"gui_default")        ; choose colormap
; add gray to colormap for continents.  w/o this, they are white, 
; and you can not see them.
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  i = NhlNewColor(wks,0.7,0.7,0.7)  

    
  res                      = True               ; plot mods desired
  res@mpFillOn          = True
  res@vcRefMagnitudeF      = 40.0               ; define vector ref mag
  res@vcRefLengthF         = 0.045              ; define length of vec ref
  res@vcGlyphStyle         = "CurlyVector"      ; turn on curley vectors
  res@vcMinDistanceF       = 0.017              ; thin out vectors
  res@vcMonoLineArrowColor = False              ; create color vectors

  res@gsnSpreadColors       = True              ; use full colormap
  res@lbLabelStride         = 2                 ; every other label
  res@gsnSpreadColorEnd     = -3                ; don't use added gray

  res@gsnLeftString         = "Surface Currents" ; change left string
  res@tiMainString          = "Vectors colored by their magnitude"

  res@gsnAddCyclic          = True                 ; add cyclic point
  plot = gsn_csm_vector_map_ce(wks,urot,vrot,res)

  end
