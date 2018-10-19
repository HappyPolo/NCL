;----------------------------------------------------------------------
; dataonmap_4.ncl
;
; Concepts illustrated:
;   - Plotting vectors on a curvilinear grid
;   - Zooming in on a particular area on a map
;----------------------------------------------------------------------
; The data file for this example can be downloaded from
;    http://www.ncl.ucar.edu/Applications/Data/#grb
;
; wget http://www.ncl.ucar.edu/Applications/Data/ruc2.bgrb.20020418.i12.f00.grb
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;-Open file and read data
  fname = "ruc2.bgrb.20020418.i12.f00.grb"
  f     = addfile (fname, "r")

  u       = f->U_GRD_252_HTGL
  v       = f->V_GRD_252_HTGL
  lat2d   = f->gridlat_252  
  lon2d   = f->gridlon_252  
  u@lat2d = lat2d
  u@lon2d = lon2d
  v@lat2d = lat2d
  v@lon2d = lon2d

;---Create plot
  wks = gsn_open_wks("png","dataonmap")      ; open a workstation

  res                 =  True              ; plot mods desired

  res@gsnMaximize     = True
  res@gsnLeftString   = "Wind"

  res@mpMinLatF       = min(lat2d)-2   ; zoom in on lat/lon area
  res@mpMaxLatF       = max(lat2d)+2
  res@mpMinLonF       = min(lon2d)-2
  res@mpMaxLonF       = max(lon2d)+2

  res@vcRefMagnitudeF = 10.0             ; define vector ref mag
  res@vcRefLengthF    = 0.045            ; define length of vec ref
  res@vcGlyphStyle    = "CurlyVector"    ; turn on curly vectors
  res@vcMinDistanceF  = 0.017            ; thin vectors

  res@tiMainString    = "Plotting data on curvilinear grid (zoomed in)"

  plot = gsn_csm_vector_map(wks,u,v,res)
end
