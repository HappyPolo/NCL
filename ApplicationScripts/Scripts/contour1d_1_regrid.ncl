load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;
; Data is stored in four columns:  station_name  lat  lon  pwv
; Read in each line as a string, and use "str_get_field" to 
; read in the fields of interest.
;
  fname = "pw.dat"
  lines = asciiread(fname,-1,"string")

;
; Use "str_get_field" to indicate which fields to read in. Each field
; is separated by spaces.
;
  lat = tofloat(str_get_field(lines(1:),2," "))
  lon = tofloat(str_get_field(lines(1:),3," "))
  pwv = tofloat(str_get_field(lines(1:),4," "))

  opt             = True
  opt@SrcGridLat  = lat
  opt@SrcGridLon  = lon
  opt@SrcRegional = True
  opt@InterMethod = "conserve"
  opt@Debug       = True
  opt@DstGridType = "0.25deg"
  opt@DstRegional = True
  opt@DstLLCorner = (/min(lat),min(lon)/)
  opt@DstURCorner = (/max(lat),max(lon)/)
  opt@ForceOverwrite = True

  pwv_regrid = ESMF_regrid(pwv,opt)

  printVarSummary(pwv_regrid)

  wks = gsn_open_wks("png","contour1d")

  res                             = True
  res@gsnMaximize                 = True

  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = 15         	; 15.25
  res@cnMaxLevelValF              = 50		; 49.75
  res@cnLevelSpacingF             = 1.125

  res@cnFillOn                    = True
  res@cnLinesOn                   = False

  res@mpMinLatF                   = min(lat)
  res@mpMinLonF                   = min(lon)
  res@mpMaxLatF                   = max(lat)
  res@mpMaxLonF                   = max(lon)

  res@mpFillOn                    = False
  res@mpOutlineDrawOrder          = "PostDraw"
  res@mpFillDrawOrder             = "PreDraw"
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpUSStateLineColor          = "Gray10"
  res@mpUSStateLineDashPattern    = 2

  res@pmTickMarkDisplayMode       = "Always"

  res@gsnAddCyclic                = False

  res@tiMainString                = "GPS PWV (18Z) (regridded)"

  map_regrid = gsn_csm_contour_map(wks,pwv_regrid,res)

  res@tiMainString                = "GPS PWV (18Z) (original)"
  res@sfXArray                    = lon
  res@sfYArray                    = lat
  map_orig   = gsn_csm_contour_map(wks,pwv,res)


;
; Now add some markers to show where the original 1D points are.
;
  mkres               = True
  mkres@gsMarkerIndex = 16    ; Filled dots
  dum_orig   = gsn_add_polymarker(wks,map_orig,lon,lat,mkres)
  dum_regrid = gsn_add_polymarker(wks,map_regrid,lon,lat,mkres)

  draw(map_orig)
  frame(wks)
  draw(map_regrid)
  frame(wks)

end 
