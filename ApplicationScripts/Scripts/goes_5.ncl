;----------------------------------------------------------------------
; goes_5.ncl
;
; Concepts illustrated:
;   - Basically... same as goes_2.ncl
;   - Reading a GOES13-IR file
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
   fili = "goes13_4_2013_208_2215.temp.IR.nc"
   f    = addfile(diri+fili,"r")
   d    = f->data          ; float data(time, yc, xc) ;
                           ; data:type = "VISR" ;
   printVarSummary(d)
   d@_FillValue = 0.0      ; manually tag value 0.0 on file
   print("d: min="+min(d)+"   max="+max(d))

   d@_FillValue = 1e20     ; don't use 0.0 as a _FillValue
    
;*********************************
; Fix the lat/lon variables so it has recognizable missing data
;*********************************
   lat2d = f->lat          ; max is 2.14329e+09
   lon2d = f->lon          ;  "  "     "
                                  ; create _FillValue
   lat2d@_FillValue = 1e20        ; could also use max(lat2d)
   lon2d@_FillValue = 1e20        ;                max(lon2d)
   
   lat2d = where(abs(lat2d).gt. 90, lat2d@_FillValue, lat2d) 
   lon2d = where(abs(lon2d).gt.360, lon2d@_FillValue, lon2d) 

   printVarSummary(lat2d)
   print("lat2d: min="+min(lat2d)+"   max="+max(lat2d))
                           
   printVarSummary(lon2d)
   print("lon2d: min="+min(lon2d)+"   max="+max(lon2d))

   lat1d  = ndtooned(lat2d)
   lon1d  = ndtooned(lon2d)
print("max(lon1d)="+max(lon1d))
                           ; region 
   print("lat1d: min="+min(lat1d)+"   max="+max(lat1d))
   print("lon1d: min="+min(lon1d)+"   max="+max(lon1d))

                           ; associate coordinates with variable
   crTime  = f->crTime     ; assorted info
   crDate  = f->crDate
   lineRes = f->lineRes
   elemRes = f->elemRes
   print("crTime ="+crTime +"    crDate ="+crDate)
   print("lineRes="+lineRes+"    elemRes="+elemRes)
print("max(lon1d)="+max(lon1d))

;*********************************
; create plot
;*********************************
   fNameBase = str_get_field(fili,1,".") + str_get_field(fili,2,".")

  ;pltName = fNameBase
   pltName = "goes"

   pltType = "png"                             ; "ps", "eps", "pdf", "png"
   pltDir  = "./"

   wks = gsn_open_wks(pltType, pltDir+pltName) 

   res                     = True
   res@gsnMaximize         = True            ; ps, pdf, pdf    
   res@gsnAddCyclic        = False           ; data not cyclic

   res@cnFillOn            = True            ; turn on color
   res@cnFillPalette       = "BlAqGrYeOrReVi200" ; set color map
   res@cnFillMode          = "RasterFill"    ; cell mode
   res@cnLinesOn           = False           ; Turn off contour lines

   res@pmTickMarkDisplayMode = "Always"      ; use NCL default 
  ;res@lbOrientation       = "Vertical"      ; vertical label bar

print("max(lon1d)="+max(lon1d))
print(lon1d)
   res@sfXArray            = lon1d
print("max(lon1d)="+max(lon1d))
   res@sfYArray            = lat1d

   res@mpMinLatF           = min(lat1d)      ; region to zoom in on
   res@mpMaxLatF           = max(lat1d)
   res@mpMinLonF           = min(lon1d)
   res@mpMaxLonF           = max(lon1d)
print("res@mpMaxLonF="+res@mpMaxLonF)
   res@mpCenterLonF        = 0.5*(res@mpMinLonF+res@mpMaxLonF )
   res@mpFillOn            = False

  ;res@mpOutlineBoundarySets = "USStates"    ; turn on state boundaries
  ;res@mpOutlineBoundarySets = "AllBoundaries"
   res@mpOutlineBoundarySets = "National"    ; turn on country boundaries

   res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
                                                ; arrays have missing values.
   res@gsnLeftString       = d@type
   res@tiMainString        = fili
   nt   = 0
   plot = gsn_csm_contour_map(wks,ndtooned(d(nt,:,:)), res)

