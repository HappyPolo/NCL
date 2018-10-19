; =================================================;
; popscal_4.ncl
; =================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; =================================================;
begin
  f = addfile("b20.007.pop.h.1000-01.nc","r")
            
  u           = f->UVEL(0,0,:,:)         ; read first time and level
  v           = f->VVEL(0,0,:,:)                                           
  t           = f->TEMP(0,0,:,:)                                             
  rot         = f->ANGLE                                                     
      
  urot        = u                        ; transfer the meta data 
  vrot        = v                                                            
                                       
  urot        = u*cos(rot) - v*sin(rot)  ; perform standard rotation  
  vrot        = u*sin(rot) + v*cos(rot)                                      

  lat2d       = f->ULAT
  lon2d       = f->ULONG

  urot@lon2d  = lon2d
  urot@lat2d  = lat2d
  vrot@lon2d  = lon2d
  vrot@lat2d  = lat2d

  t@lat2d     = lat2d
  t@lon2d     = lon2d
; =================================================;
; create vector plot
; =================================================;
  wks  = gsn_open_wks("png","popscal")             ; send graphics to PNG file

  res                       = True                 ; plot mods desired
  res@vcRefMagnitudeF       = 30.0                 ; define vector ref mag
  res@vcRefLengthF          = 0.045                ; define length of vec ref
  res@vcMinDistanceF        = 0.019                ; thin out vectors
  res@vcGlyphStyle          = "CurlyVector"        ; turn on curly vectors
  res@gsnLeftString         = "Surface Currents"   ; change left string
  res@tiMainString          = "Orthographic Projeciton"   ; title
  
  res@gsnDraw               = False                ; don't draw yet
  res@gsnFrame              = False                ; don't advance frame yet

  res@gsnLeftString         = ""                   ; turn off strings
  res@gsnRightString        = ""

  plot = gsn_csm_vector(wks,urot,vrot,res)
; =================================================;
; create contour plot
; =================================================;
  res_cn                      = True
  res_cn@cnFillOn             = True                 ; turn on color fill
  res_cn@cnLinesOn            = False                ; turn off contour lines
  res_cn@cnFillPalette        = "gui_default"        ; set color map

  res_cn@gsnDraw              = False                ; don't draw yet
  res_cn@gsnFrame             = False                ; don't advance frame yet

  res_cn@mpProjection         = "Orthographic"       ; choose projection
  res_cn@mpCenterLonF         = -120.                ; choose center lon
  res_cn@mpCenterLatF         = 50.                  ; choose center lat

  res_cn@gsnAddCyclic         = True

  pltBase = gsn_csm_contour_map(wks,t,res_cn)
; =================================================;
; now overlay vector plot on top of scalar plot
; =================================================;
  overlay(pltBase,plot)
  draw(wks)
  frame(wks)
  end
