;----------------------------------------------------------------------
; goes_2.ncl
;
; Concepts illustrated:
;   - Reading a GOES-12 file
;   - Fixing the lat, lon and data values so that outliers are recognized
;   - Using triangular mesh to create contours
;----------------------------------------------------------------------
; Because the lat/lon arrays have missing values, it is necessary to
; plot this data with res@trGridType set to "TriangularMesh".
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;*********************************
; read variable
;*********************************
   diri = "./"
   fili = "goes12.2008.328.024514.BAND_04.nc"
   f    = addfile(diri+fili,"r")
   d    = f->data          ; float data(time, yc, xc) ;
                           ; data:type = "VISR" ;
   printVarSummary(d)
;*********************************
; Fix the variables so it has recognizable missing data
;*********************************
   d@_FillValue   = 255.   ; guess

   lat2d  = f->lat
   lon2d  = f->lon

   lat1d  = ndtooned(f->lat)
   lon1d  = ndtooned(f->lon)

   lat1d@_FillValue = max(lat1d)
   lon1d@_FillValue = max(lon1d)
                           ; region 
   print("lat1d: min="+min(lat1d)+"   max="+max(lat1d))
   print("lon1d: min="+min(lon1d)+"   max="+max(lon1d))

   crTime  = f->crTime     ; assorted info
   crDate  = f->crDate
   lineRes = f->lineRes
   elemRes = f->elemRes
   print("crTime ="+crTime +"    crDate ="+crDate)
   print("lineRes="+lineRes+"    elemRes="+elemRes)

;*********************************
; create plot
;*********************************
   sfx     = get_file_suffix(fili,0)           ; use file name         

  ;pltName = sfx@fBase+"_"+cnFill
   pltName = "goes"

   pltType = "png"                             ; "ps", "eps", "pdf", "png", "x11"
   pltDir  = "./"

   wks = gsn_open_wks(pltType, pltDir+pltName) 

   res                     = True
   res@gsnMaximize         = True            ; ps, pdf, pdf    

   res@cnFillOn            = True            ; turn on color
   res@cnFillPalette       = "amwg"          ; set color map
   res@cnFillMode          = "RasterFill"    ; cell mode
   res@cnLinesOn           = False           ; Turn off contour lines

   res@gsnAddCyclic        = False           ; data not cyclic
   res@pmTickMarkDisplayMode = "Always"      ; use NCL default 
  ;res@lbOrientation       = "Vertical"      ; vertical label bar

   res@mpMinLatF           = min(lat1d)    ; region to zoom in on
   res@mpMaxLatF           = max(lat1d)
   res@mpMinLonF           = min(lon1d)
   res@mpMaxLonF           = max(lon1d)
   res@mpFillOn            = False

   res@sfXArray            = lon1d
   res@sfYArray            = lat1d
  ;res@mpOutlineBoundarySets = "USStates"    ; turn on state boundaries
  ;res@mpOutlineBoundarySets = "AllBoundaries"
   res@mpOutlineBoundarySets = "National"    ; turn on country boundaries

   res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
                                                ; arrays have missing values.
   res@gsnLeftString       = d@type
   res@tiMainString        = fili
   nt   = 0
   dat1d  = ndtooned(d(nt,:,:))
   
   plot = gsn_csm_contour_map(wks,dat1d, res)

