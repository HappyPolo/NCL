;03.ncl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  
do i=1,800
  fv                            =addfile("vwnd.mon.mean.nc", "r")
  fw                            =addfile("omega.mon.mean.nc","r")
  v                             =fv->vwnd(i,:,:,:)
  w                             =fw->omega(i,:,:,:)
end do  

  

  wAve                          =avg(w(0,:,:,{90}))           ; used for scaling
  vAve                          =avg(v(0,:,:,{90}))
  scale                         =fabs(vAve/wAve)
  wscale                        = w*scale                       ; now scale
  copy_VarCoords(w, wscale)              ; copy coordinate variables 



  wks                           =gsn_open_wks ("x11", "vector" )        ; send graphics to PNG file
  res                           = True                     ; plot mods desired
  

  res@cnLineLabelsOn            = False                ; turn off line labels
  res@cnFillOn                  = True                 ; turn on color fill
  res@cnFillPalette             = "BlAqGrYeOrReVi200"  ; choose color map

  res@lbLabelStride             = 2                    ; every other color

  res@vcRefMagnitudeF           = 3.0                ; define vector ref mag
  res@vcRefLengthF              = 0.045              ; define length of vec ref
  res@vcGlyphStyle              = "CurlyVector"      ; turn on curly vectors
  res@vcMinDistanceF            = 0.01               ; thin out vectors
  res@vcMapDirection            = False


  

  plot =gsn_csm_pres_hgt_vector(wks,w(0,:,:{90}), v(0,:,:{90}),wscale(0,:,:{90}), res)