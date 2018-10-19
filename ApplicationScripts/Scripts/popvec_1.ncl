; =================================================;
; popvec_1.ncl
; =================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
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
  urot@lon2d  = lon2d(::6,::6)
  urot@lat2d  = lat2d(::6,::6)
  vrot@lon2d  = lon2d(::6,::6)
  vrot@lat2d  = lat2d(::6,::6)
; =================================================;
; create plots
; =================================================;
  wks  = gsn_open_wks("png","popvec")              ; send graphics to PNG file

  res                       = True                 ; plot mods desired
  res@vcRefMagnitudeF       = 40.0                 ; define vector ref mag
  res@vcRefLengthF          = 0.045                ; define length of vec ref
  res@vcGlyphStyle          = "CurlyVector"        ; turn on curly vectors
  res@gsnLeftString         = "Surface Currents"   ; change left string
  res@tiMainString          = "Vectors from POP"   ; title
  res@gsnAddCyclic          = True                 ; add cyclic point

  plot = gsn_csm_vector_map(wks,urot(::6,::6),vrot(::6,::6),res)

  end
