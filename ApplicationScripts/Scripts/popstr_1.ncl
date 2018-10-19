; ===================================================;
; popstr_1.ncl
; ===================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ===================================================;
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
  urot@lon2d  = lon2d(::4,::4)
  urot@lat2d  = lat2d(::4,::4)
  vrot@lon2d  = lon2d(::4,::4)
  vrot@lat2d  = lat2d(::4,::4)
; ===================================================;
; create plots
; ===================================================;
  wks  = gsn_open_wks("ps","popstr")            ; open a ps file
  res                 = True                    ; plot mods desired
  res@tiMainString    = "POP streamline plot"   ; add title
  res@gsnLeftString   = "Streamline"            ; change left string
  res@gsnAddCyclic    = True                    ; add cyclic point

  plot = gsn_csm_streamline_map_ce(wks,urot(::4,::4),vrot(::4,::4),res)


  end

