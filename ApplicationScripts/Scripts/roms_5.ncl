;*************************************************
; roms_5.ncl
;
; Concepts illustrated:
;   - Plotting ROMS data
;   - Loading NCL functions from another script
;   - Changing the reference annotation string for vectors
;   - Overlaying vectors and filled contours on a map
;
; roms depth slice using roms_3d_interp with velocity overlay
; note: roms_3d_interp is working on "rho" coords
; if you specify variable "u" or "v" it is transfering them
; first to the "rho" and than interpolate.
;
;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "./ROMS_utils.ncl"
begin
;************************************************
; User settings
;************************************************
   date  = 20121002
   path  ="/mnt/drobilica2/OPERATIONAL/ROMS/archive/"
   fhis  = path + "roms_avg_arch_" + sprinti("%i",date) + ".nc"

   outfile = "roms_5"
   depth = -20.0
   rec   = 0
   
;***********************************************
; Read data and interpolate
;***********************************************
   his   =  addfile (fhis,"r")
   lon2d = his->lon_rho
   lat2d = his->lat_rho
   out   = roms_3d_interp(his,"temp",rec,depth)
   ur    = roms_3d_interp(his, "u", rec, depth) ; they are automatically put to "rho"
   vr    = roms_3d_interp(his, "v", rec, depth)
   angle = his->angle
   uvrot = uv_rot(ur,vr,angle)
   urr   = uvrot(0,:,:)
   vrr   = uvrot(1,:,:)

   delete(uvrot)
   delete(ur)
   delete(vr)

   urr@lat2d = lat2d
   urr@lon2d = lon2d
   vrr@lat2d = lat2d
   vrr@lon2d = lon2d
   out@lat2d = lat2d
   out@lon2d = lon2d

   minValue  = 15.0
   maxValue  = 25.0
   step   = 0.2
   stride = 10
   
   ;************************************************
   ; create plot
   ;************************************************
   wks_type = "newpng"        ; or "eps"
   wks_type@wkOrientation = "Portrait"
   wks  = gsn_open_wks (wks_type, outfile)            ; open workstation
   gsn_define_colormap(wks, "BlAqGrYeOrRevi200")
   i = NhlNewColor(wks,0.8,0.8,0.8)                   ; add gray to colormap
                                           
   vres1 = True               ; plot mods desired
   vres1@gsnDraw              = False
   vres1@gsnFrame             = False
   vres1@gsnMaximize          = True    ; Maximize plot in frame
   vres1@gsnPaperOrientation  = "Portrait"
   vres1@cnFillDrawOrder      = "PreDraw"
   vres1@cnFillOn             = True               ; turn on color for contours
   vres1@cnLinesOn            = False              ; turn off contour lines
   vres1@cnLineLabelsOn       = False              ; turn off contour line labels
   vres1@cnFillMode           = "RasterFill"
   vres1@gsnScalarContour     = True               ; contours desired
   vres1@gsnSpreadColors      = True               ; use full color map
   vres1@gsnSpreadColorEnd    = -2
   vres1@mpLandFillColor      = "gray"            ; set land to be gray
   vres1@lbLabelBarOn 	     = True
   vres1@lbLabelStride        = stride
   vres1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
   vres1@cnMinLevelValF       = minValue                ; set min contour level
   vres1@cnMaxLevelValF       = maxValue                ; set max contour level
   vres1@cnLevelSpacingF      = step                 ; set contour spacing
   vres1@lbOrientation        = "Vertical"     ; /Vertical label bar
   vres1@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer
   vres1@pmLabelBarDisplayMode = "Always"          ; Turn on a label bar.
   vres1@lbPerimOn             = False             ; no box around it
   vres1@lbBoxLinesOn         = True               ; Yes/No labelbar box lines.
   vres1@vcRefMagnitudeF           = 0.25              ; define vector ref mag
   vres1@vcRefLengthF              = 0.03              ; define length of vec ref
   vres1@vcRefAnnoOrthogonalPosF   = -1.0            ; move ref vector
   vres1@vcRefAnnoArrowLineColor   = "black"         ; change ref vector color
   vres1@vcRefAnnoArrowUseVecColor = False           ; don't use vec color for ref
   vres1@vcRefAnnoString1 = "0.25 m/s"
   vres1@vcLabelsOn = False
   vres1@vcLineArrowColor = "black"
   vres1@vcRefAnnoOn = True
   vres1@vcMonoLineArrowColor  = True             ; vec's colored by their mag
   vres1@vcLineArrowHeadMaxSizeF = 0.005
   vres1@vcLineArrowHeadMinSizeF = 0.003  
   vres1@vcMinDistanceF           = 0.01            ; thin vectors
   vres1@vcGlyphStyle          = "CurlyVector"     ; turn on curly vectors
   
   offset = 0.1
   lon1=min(lon2d)-offset
   lat1=min(lat2d)+offset
   lon2=max(lon2d)-offset
   lat2=max(lat2d)+offset
  ;lon1=14.0
  ;lat1=44.5
  ;lon2=15+15.0/60.0
  ;lat2=45+25.0/60.0
   
; MAP
  vres1@mpProjection = "Mercator"
  vres1@mpLimitMode         = "Corners"             ; choose range of map
  vres1@mpLeftCornerLatF    = lat1
  vres1@mpLeftCornerLonF    = lon1
  vres1@mpRightCornerLatF   = lat2
  vres1@mpRightCornerLonF   = lon2
  vres1@mpDataBaseVersion      = "HighRes"          ; use high resolution coast
  vres1@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
; vres1@mpLandFillColor      = -1
   
  vres1@gsnLeftString  = "temperature and velocity at 10m"
  vres1@gsnRightString    = ""
  plot = gsn_csm_vector_scalar_map(wks,urr,vrr,out,vres1)
  draw(plot)
  frame(wks)

end
