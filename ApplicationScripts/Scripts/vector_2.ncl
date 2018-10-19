;----------------------------------------------------------------------
; vector_2.ncl
;
; Concepts illustrated:
;   - Overlaying line contours, vectors, and filled contours on a map
;   - Manually attaching lat/lon coordinate arrays to a variable
;   - Changing the length of the smallest vector as a fraction of the reference vector
;   - Drawing curly vectors
;   - Setting the color for vectors
;   - Moving the vector reference annotation to the top right of the plot
;   - Making the labelbar be vertical
;   - Increasing the thickness of vectors
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

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
  wks = gsn_open_wks("png","vector")            ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrReVi200")

  res                      = True               ; plot mods desired

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@cnFillPalette        = cmap(17:,:)        ; subset the color map
  res@gsnScalarContour     = True               ; contours desired

  res@mpLandFillColor       = "gray"            ; set land to be gray
  res@mpMinLonF            =  65.               ; select a subregion
  res@mpMaxLonF            =  95.
  res@mpMinLatF            =   5. 
  res@mpMaxLatF            =  25.

  res@lbOrientation            = "Vertical"     ; vertical label bar
  res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer

; note, when doing a subregion, NCL determines the range of the data from
; the full domain. If you wish to just consider the domain you are plotting,
; you must manually set those levels.

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = 24.0               ; set min contour level
  res@cnMaxLevelValF       = 29                 ; set max contour level
  res@cnLevelSpacingF      = 0.10               ; set contour spacing
  res@tiMainString         = "Sea Surface Temperatures and 1000 mb Winds"

  res@vcRefMagnitudeF           = 4.0             ; define vector ref mag
  res@vcRefLengthF              = 0.045           ; define length of vec ref
  res@vcRefAnnoOrthogonalPosF   = -1.0            ; move ref vector
  res@vcRefAnnoArrowLineColor   = "black"         ; change ref vector color
  res@vcRefAnnoArrowUseVecColor = False

  res@vcGlyphStyle            = "CurlyVector"     ; turn on curley vectors
  res@vcLineArrowColor        = "white"           ; change vector color
  res@vcLineArrowThicknessF   = 2.0               ; change vector thickness
  res@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last

  res@gsnDraw          = False                    ; turn off draw and frame
  res@gsnFrame         = False                    ; b/c this is an overlay plot
  plot=gsn_csm_vector_scalar_map_ce(wks,u(ind_uv,:,:),v(ind_uv,:,:),sst(ind_sst,:,:),res)


;---Add contours of wind speed to plot
  delete(res)
  res                 = True
  res@gsnDraw         = False
  res@gsnFrame        = False
  res@gsnLeftString   = ""
  res@gsnRightString  = ""
  res@gsnCenterString = ""
  res@cnInfoLabelOrthogonalPosF = 0.15  ; move info label down

  cplot = gsn_csm_contour(wks,speed,res)
  overlay(plot,cplot)
  draw(plot)
  frame(wks)
end
