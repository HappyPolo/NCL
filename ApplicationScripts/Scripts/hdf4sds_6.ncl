;***************************************************************
; hdf4sds_6.ncl
;***************************************************************
;   - Reading HDF4-SDS files
;*********** Load Libraries ************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
begin
;***************************************************************
; User Input
;***************************************************************
                                             ; INPUT
   diri    = "./"                            ; input directory
   fili    = "2A12.100702.71931.6.HDF"       ;       file
   var     = "latentHeat"                    ; desired variable                   

                                             ; OUTPUT
   PLOT    = True                            ; create a plot [?]
   pltDir  = "./"                            ; directory for plot output
  ;pltName = "2A12.100702.71931.6"           ; plot name 
   pltName = "hdf4sds"                       ; plot name 
   pltType = "png"                           ; send graphics to PNG file
;***************************************************************
; End User Input
;***************************************************************
; Read hdf 
;***************************************************************

   f      = addfile (diri+fili, "r")
  ;print(f)

   lat  = f->geolocation(:,:,0)            ; (scan, pixel)
   lon  = f->geolocation(:,:,1)            

   lat@units = "degrees_north"             ; add units
   lon@units = "degrees_east"

  ;printMinMax(lat, True)
  ;printMinMax(lon, True)

   xs     = f->$var$                       ; ( scan, pixel, layer )
   xs@_FillValue = inttoshort( -9999 )     ; visually look at file/data
   xs@long_name  = xs@hdf_name
  ;printVarSummary(xs)
  ;printMinMax(xs, True)
        
   x      = short2flt( xs )                ; unpack the variable
  ;printVarSummary(x)
   delete( xs )                            ; no longer needed
   
   dimx   = dimsizes(x)
   nscan  = dimx(0)
   npix   = dimx(1)
   nlayer = dimx(2)
   layer  = ispan(1,nlayer,1)
   layer@long_name = "layer"

;***************************************************************
; Simple data exploration:   Distribution statistics
;***************************************************************

   opt   = True
   opt@PrintStat = True
   statb = stat_dispersion(x, opt )        ; all layers

;************************************************
; Create plot 
;************************************************
   x@lat2d = lat
   x@lon2d = lon

   wks    = gsn_open_wks(pltType, pltDir+pltName)

  ;setvalues NhlGetWorkspaceObjectId()
  ;    "wsMaximumSize": 100000000      ; need some extra workspace
  ;end setvalues
   
   res                      = True               ; plot mods desired
   res@gsnAddCyclic         = False              ; data not global

   res@gsnMaximize          = True               ; make ps/eps/pdf large
   res@gsnPaperOrientation  = "portrait"
 
   res@cnFillOn             = True               ; turn on color fill
   res@cnFillPalette        = "amwg"             ; set color map
   res@cnLinesOn            = False              ; turn of contour lines
   res@cnLineLabelsOn       = False              ; Turn off contour lines
   res@cnFillMode           ="RasterFill"        ; Raster Mode
 
  ;res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  ;res@cnMinLevelValF       =                    ; set min contour level
  ;res@cnMaxLevelValF       =                    ; set max contour level
  ;res@cnLevelSpacingF      =                    ; set contour spacing

   res@lbOrientation        = "vertical"   ; vertical label bar
   res@lbLabelFontHeightF   = 0.012        ; change font size [make smaller]
   res@pmLabelBarWidthF     =  0.1         ; make thinner

; GLOBE: This is slow

   res@mpMinLatF            = min( (/min(lat), -40/) )     
   res@mpMaxLatF            = max( (/max(lat),  40 /) )
   res@mpMinLonF            = min(lon) 
   res@mpMaxLonF            = max(lon)
  ;res@mpCenterLonF         = (res@mpMinLonF+res@mpMaxLonF)*0.5
   res@mpCenterLonF         = 80.
   res@mpFillOn             = False
   res@mpOutlineOn          = True

  ;res@mpShapeMode          = "FreeAspect"
  ;res@vpWidthF             = 0.8
  ;res@vpHeightF            = 0.4

  ;res@gsnLeftString        = 
   res@tiMainString         = fili 

   do nl=7,7   ; 0,nlayer-1
      res@gsnRightString    = "layer="+(nl+1) 
      plot = gsn_csm_contour_map_ce(wks,x(:,:,nl), res)
   end do

; INDIA REGION

   res@mpMinLonF            =  70.
   res@mpMaxLonF            =  90.
   res@mpMinLatF            =   5.
   res@mpMaxLatF            =  25.

   res@mpOutlineBoundarySets  = "National"  ; turn on country boundaries
   res@mpDataSetName        = "Earth..4"    ; database for non-USA divisions
   res@mpDataBaseVersion    = "MediumRes"   ; Medium resolution database
   res@mpOutlineSpecifiers  = (/"India:states"/)

   lat1d = ndtooned( lat )
   lon1d = ndtooned( lon )
   ii    = ind(lon1d.ge.res@mpMinLonF .and. lon1d.le.res@mpMaxLonF .and. \
               lat1d.ge.res@mpMinLatF)

   res@sfXArray = lon1d(ii)
   res@sfYArray = lat1d(ii)

   do nl=7,7   ; 0,nlayer-1
      x1d   = ndtooned( x(:,:,nl) )

      res@gsnLeftString = x@long_name
      res@gsnRightString   = "layer="+(nl+1) 

      plot = gsn_csm_contour_map_ce(wks,x1d(ii), res)
   end do

   delete(res@sfXArray)
   delete(res@sfYArray)
   delete(x1d)
   delete(ii)

; PROFILE: pick locations with large latent heat ( > 1500 )

  nl  = 7                   ; use layer 7 (arbitrary)
  x1d = ndtooned( x(:,:,nl) )
 ;printMinMax(x1d, True)

  jj  = ind(lon1d.ge.res@mpMinLonF .and. lon1d.le.res@mpMaxLonF .and. \
            lat1d.ge.res@mpMinLatF .and. lat1d.le.res@mpMaxLatF .and. \  
            x1d.gt.1500)
  print(jj)
  if (.not.ismissing(jj(0))) then
      
       resxy                 = True              ; plot mods desired
       resxy@trYReverse      = True              ; reverse Y-axis
      ;resxy@xyDashPatterns  = 1                 ; choose dash patterns
       resxy@xyLineColor     = "blue"
       resxy@xyLineThicknesses = 2.0

       resxy@tiMainString    = fili

       njj   = dimsizes(jj)
       do n=0,njj-1
          jr = ind_resolve(jj(n), (/nscan,npix/))
          nl = jr(n,0)
          ml = jr(n,1)
          resxy@gsnCenterString  = "lat="+lat(nl,ml)+": lon="+lon(nl,ml)
          pltxy  = gsn_csm_xy (wks,x(nl,ml,:),layer,resxy) 
       end do
  end if
end

