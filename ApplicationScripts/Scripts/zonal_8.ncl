;************************************************
; zonal_8.ncl
;
; Concepts illustrated:
;   - Attaching a zonal means plot to a cylindrical equidistant contour plot
;   - Adding an extra curve to a zonal means plot
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
  a = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc", "r")
  u = a->U(1,:,:)                                ; read July zonal winds

  wks  = gsn_open_wks("png","zonal")                   ; send graphics to PNG file

  res                            = True                ; plot mods desired

  res@gsnDraw                    = False
  res@gsnFrame                   = False

  res@mpFillOn                   = False               ; turn off gray map
  res@mpOutlineDrawOrder         = "PreDraw"           ; draw outline first

  res@cnFillOn                   = True

;---Create the plots, but don't draw them yet
  zres  = True
  plot  = gsn_csm_contour_map(wks,u,res)
  zonal = gsn_csm_attach_zonal_means(wks,plot,u,zres)

;---Create dummy data object to add new curve to zonal plot
  x = (/ 0,  5,10, 15,20,25,30,35,40/)
  y = (/-30,-20,0,-10,20,30,25,20,40/)

  dataid = create "xyData" coordArraysClass defaultapp
    "caYArray": y
    "caXArray": x
  end create

;---Add new data object plot to the zonal plot
  dataspec = NhlAddData(zonal,"xyCoordData",dataid)

;---Set some resources for the new curve.
  setvalues dataspec
    "xyLineColor"      : "NavyBlue"
    "xyLineThicknessF" : 2.
  end setvalues

;---This will draw everything, including the new curve
  draw(plot)
  frame(wks) 

end
