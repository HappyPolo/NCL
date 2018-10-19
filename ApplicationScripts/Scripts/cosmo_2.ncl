;----------------------------------------------------------------------
; cosmo_2.ncl
;
; Concepts illustrated:
;   - Plotting COSMO model data from MeteoSwiss
;   - Plotting data from a rotated lat-lon grid
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

 ; open file
 fname = "lfff01000000"
 cname = "lfff00000000c"
 ftype = "nc"
 lfile = addfile(fname+"."+ftype,"r")
 cfile = addfile(cname+"."+ftype,"r")

 ; read water vapour and level height
 jval  = 147 ; rotated latitude index for cross-section
 if (ftype .eq. "grb") then
   qv = lfile->QV_GDS10_HYBY(:,jval,:)
   hhl = cfile->HH_GDS10_HYBL(:,jval,:)
 end if
 if (ftype .eq. "nc") then
   qv = lfile->QV(0,:,jval,:)
   hhl = cfile->HHL(0,:,jval,:)
 end if
 if (.not. isvar("qv")) then
   print("Only grb or nc file type is supported!")
   exit
 end if

 ; get dimensions
 nlev = dimsizes(qv(:,0))
 nlon = dimsizes(qv(0,:))

 ; setup dimension for GRIB format
 if (ftype .eq. "grb") then
    coords = str_split(qv@coordinates, " ")
    lon = cfile->$coords(1)$
    rlon = fspan(lon@Lo1,lon@Lo2,nlon)
    rlon@long_name = "Rotated longitude"
    rlon@units = "deg"
    qv!1 = "rlon"
    qv&rlon = rlon
 end if

 ; close files
 delete(cfile)
 delete(lfile)

 ; convert units
 qv = 1000.0 * qv  ; g/kg
 qv@unit = "g kg-1"
 hhl = 0.001 * hhl ; km

 ; compute data positions
 x2d = conform_dims((/nlev,nlon/), qv&rlon, 1)
 y2d = 0.5*(hhl(0:nlev-1,:)+hhl(1:nlev,:))

 ; open graphic port
 ptype = "png"              ; send graphics to PNG file
 wks = gsn_open_wks(ptype,"cosmo")

 ; setup irregular mesh
 res                        = True
 res@trGridType             = "TriangularMesh" ; used for irregular mesh triangulation
 res@sfXArray               = x2d
 res@sfYArray               = y2d
 res@tiXAxisString          = "Rotated Longitude [deg]"
 res@tiYAxisString          = "Height [km]"
 ;;res@trXMinF                = 
 ;;res@trXMaxF                = 
 res@trYMinF                = 0.0
 res@trYMaxF                = 10.0

 ; setup contour plot resources
 res@vpWidthF               = 0.85
 res@vpHeightF              = 0.5
 ;;res@cnFillMode             = "RasterFill"
 res@gsnMaximize            = True             ; maxmize plot in frame
 res@cnFillOn               = True             ; turn on color 
 res@cnFillPalette          = "precip_11lev"   ; set color map
 res@cnLinesOn              = False            ; no contour lines
 res@cnLineLabelsOn         = False            ; no contour labels
 res@cnLevelSelectionMode   = "ManualLevels"   ; manual level selection
 res@cnMinLevelValF         = 0.0              ; water (blue) is below 0.0m
 res@cnMaxLevelValF         = 5.0           ; snow/ice (white) is at 3000.0m
 res@pmTickMarkDisplayMode  = "conditional"
 res@gsnAddCyclic           = False
 res@lbOrientation          = "vertical"
;; res@lbLabelFontHeightF     = 0.015
;; res@lbLabelStride          = 2

 ; postpone drawing
 res@gsnDraw                = False
 res@gsnFrame               = False

 ; make contour + map plot
 pl = gsn_csm_contour(wks, qv, res)
 delete(res)

 ; add topography
 res                        = True
 res@gsLineColor            = "black"
 res@gsLineThicknessF       = 1.0
 pl@topopoly = gsn_add_polyline(wks, pl, qv&rlon, hhl(nlev,:), res)
 delete(res)

 ; draw and frame
 draw(pl)
 frame(wks)

 ; cleanup
 delete(wks)

end
