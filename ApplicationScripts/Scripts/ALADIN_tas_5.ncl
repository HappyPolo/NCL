load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read data
  filename   = "tas_MED-44_ERAINT_evaluation_r1i1p1_CNRM-ALADIN52_v1_mon_197901-201012.nc"
  a          = addfile(filename,"r")
  tas        = a->tas(0,:,:)
  lc         = a->Lambert_Conformal     ; contains map projection information
  lat2d      = a->lat
  lon2d      = a->lon
  nlat       = dimsizes(lat2d(:,0))
  nlon       = dimsizes(lat2d(0,:))

  tas@lat2d = lat2d                    ; for plotting
  tas@lon2d = lon2d

;---Open workstation and change color map
  wks = gsn_open_wks("ps","ALADIN_tas_5")
  gsn_define_colormap(wks,"rainbow")

;---Set some resources
  res                   = True

  res@gsnMaximize       = True     ; maximize plot in frame
  res@tiMainString      = "CORDEX Mediterranean ALADIN5.2 0.5 deg ERA"

  res@mpProjection      = "LambertConformal"          ; Change map projection
;
; Not sure why these values work for the parallels. Normally 
; we would use the 'standard_parallel' attribute attached
; to this variable.
;
  res@mpLambertParallel1F = lc@latitude_of_projection_origin
  res@mpLambertParallel2F = lc@latitude_of_projection_origin
  res@mpLambertMeridianF  = lc@longitude_of_central_meridian

  res@mpLimitMode         = "Corners"
  res@mpLeftCornerLatF    = lat2d(0,0)
  res@mpLeftCornerLonF    = lon2d(0,0)
  res@mpRightCornerLatF   = lat2d(nlat-1,nlon-1)
  res@mpRightCornerLonF   = lon2d(nlat-1,nlon-1)

  res@mpDataBaseVersion   = "MediumRes"     ; Better map outlines

  res@pmTickMarkDisplayMode = "Always"      ; Turn on tickmarks

  res@cnFillOn          = True          ; Turn on contour fill
  res@cnLinesOn         = False         ; Turn off contour lines

  plot = gsn_csm_contour_map(wks,tas,res)
end


