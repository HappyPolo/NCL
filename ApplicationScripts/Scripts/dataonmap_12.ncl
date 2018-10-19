;----------------------------------------------------------------------
; Downloaded data containing ocean surface currents at 1/72 year
; intervals (roughly every 5 days) from: 
;
; ftp://podaac-ftp.jpl.nasa.gov/OceanCirculation/oscar/preview/L4/resource/LAS/oscar_third_deg_180/
;
; This data goes from -180 to 180 longitude.
;----------------------------------------------------------------------

begin  
  filename = "oscar_vel2016_180.nc"

  f = addfile(filename,"r")
  u = f->u
  v = f->v

  printVarSummary(u)
  printMinMax(u,0)
  printMinMax(v,0)

;----------------------------------------------------------------------
; Replace the NaN values with _FillValue.
;
; The _FillValue is also equal to NaN, so have to replace this too.
;----------------------------------------------------------------------
  u@_FillValue = default_fillvalue(typeof(u))
  v@_FillValue = default_fillvalue(typeof(v))
  replace_ieeenan (u,u@_FillValue,0)
  replace_ieeenan (v,v@_FillValue,0)

;---Print min/max after NaN fix
  printMinMax(u,0)
  printMinMax(v,0)

  wks = gsn_open_wks("png","dataonmap")

  res                      = True
  res@stMonoLineColor      = False
  res@stLevelSelectionMode = "ExplicitLevels"
  res@stLevels             = ispan(1,30,1)/10.
  res@gsnAddCyclic         = False
  res@lbLabelFontHeightF   = 0.01
  res@pmLabelBarWidthF     = 0.8

  plot = gsn_csm_streamline_map(wks,u(5,0,:,:),v(5,0,:,:),res)

end
