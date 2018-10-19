load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin

;---Open netCDF file
  a = addfile("sst8292.nc","r")
  b = addfile("uvt.nc","r")
;
; Read in Sea Surface Temperature Anomalies
; Read in U and V at 1000 mb [subscript 0]
; Determine the subscripts corresponding to Jan 88
;
  sst      = a->SST
  u        = b->U(:,0,:,:)
  v        = b->V(:,0,:,:)
  lat_uv   = b->lat
  lon_uv   = b->lon
  date_sst = a->date
  date_uv  = b->date
  ind_sst  = ind(date_sst.eq.198801)
  ind_uv   = ind(date_uv .eq.198801)
  speed    = sqrt(u(ind_uv,:,:)^2+v(ind_uv,:,:)^2)
  speed@long_name = "Wind Speed"
  speed!0  = "lat"
  speed!1  = "lon"
  speed&lat= lat_uv
  speed&lon= lon_uv

;---Create plot
  wtype = "png"
  wtype@wkWidth = 1000
  wtype@wkHeight = 1000
  wks = gsn_open_wks(wtype,"vector")             ; open a ps file
  cmap = read_colormap_file("BlAqGrYeOrRevi200")

  res                      = True               ; plot mods desired

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@cnFillPalette        = cmap(17:,:)        ; subset the color map
  res@gsnScalarContour     = True               ; contours desired

  res@gsnRightString = ""
  res@gsnLeftString = ""
  res@mpLandFillColor       = "gray"            ; set land to be gray
  res@mpMinLonF            =  65.               ; select a subregion
  res@mpMaxLonF            =  95.
  res@mpMinLatF            =   5. 
  res@mpMaxLatF            =  25.

  res@mpDataBaseVersion = "HighRes"
  res@mpNationalLineThicknessF = 3.0
  res@mpGeophysicalLineThicknessF = 3.0

  res@lbLabelBarOn = False
  res@vcRefAnnoOn = False
  res@gsnTickMarksOn = False
;  res@lbOrientation            = "Vertical"     ; vertical label bar
;  res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer

; note, when doing a subregion, NCL determines the range of the data from
; the full domain. If you wish to just consider the domain you are plotting,
; you must manually set those levels.

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = 24.0               ; set min contour level
  res@cnMaxLevelValF       = 29                 ; set max contour level
  res@cnLevelSpacingF      = 0.10               ; set contour spacing

  res@vcRefMagnitudeF           = 4.0             ; define vector ref mag
  res@vcRefLengthF              = 0.045           ; define length of vec ref
  res@vcRefLengthF              = 0.045           ; define length of vec ref
  res@vcRefAnnoOrthogonalPosF   = -1.0            ; move ref vector
  res@vcRefAnnoArrowLineColor   = "black"         ; change ref vector color

  res@vcGlyphStyle            = "CurlyVector"     ; turn on curley vectors
  res@vcLineArrowThicknessF   = 3.0               ; change vector thickness
  res@mpFillOn = False

  res@gsnDraw          = False                    ; turn off draw and frame
  res@gsnFrame         = False                    ; b/c this is an overlay plot
  plot=gsn_csm_vector_scalar_map_ce(wks,u(ind_uv,:,:),v(ind_uv,:,:),sst(ind_sst,:,:),res)


  draw(plot)
  frame(wks)
end
