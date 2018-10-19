load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  filename = "DXGLOB22+2003070106+O00.nc"
  f        = addfile (filename,"r")

;---Read data and convert units
  apas       = f->air_pressure_at_surface      ; time x lat x lon
  apas       = apas * 0.01                     ; Pa to hPa
  apas@units = "hPa"

;---Start the graphics
  wks = gsn_open_wks("ps","MOCAGE_DX_apas")  
  gsn_define_colormap(wks,"BlAqGrYeOrRe")       ; Change color map

;---Set some resources
  res              = True

  res@gsnMaximize     = True

  res@cnFillOn        = True            ; Turn on contour fill
  res@cnLinesOn       = False           ; Turn off contour lines
  res@cnLevelSpacingF = 20              ; Default was 40

  res@tiMainString    = filename        ; Use filename as title

  nt = 0                 ; time index
  plot = gsn_csm_contour_map(wks,apas(nt,:,:),res)

end
