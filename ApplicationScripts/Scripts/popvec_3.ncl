; =================================================;
; popvec_3.ncl
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

  urot@lon2d  = lon2d
  urot@lat2d  = lat2d
  vrot@lon2d  = lon2d
  vrot@lat2d  = lat2d
; =================================================;
; create plots
; =================================================;
  wks  = gsn_open_wks("ps","popvec")               ; open a ps file

  res                       = True                 ; plot mods desired
  res@vcRefMagnitudeF       = 30.0                 ; define vector ref mag
  res@vcRefLengthF          = 0.045                ; define length of vec ref
  res@vcMinDistanceF        = 0.017                ; thin out vectors
  res@vcGlyphStyle          = "CurlyVector"        ; turn on curley vectors
  res@vcRefAnnoOrthogonalPosF   = -1.0                 ; move reference vector up

  res@gsnLeftString         = "Surface Currents"   ; change left string
  res@tiMainString          = "Vectors from POP"   ; title
 
  res@mpMaxLatF             = 30.                  ; zoom in on map
  res@mpMinLatF             =  9.
  res@mpMinLonF             = -100.
  res@mpMaxLonF             = -55.

; note, this data has 2D lat/lon coordinates. gsnAddCyclic is set to
; false by default. You do not have to set it here like we do for any 
; other zoom plot.

  plot = gsn_csm_vector_map_ce(wks,urot,vrot,res)

  end
