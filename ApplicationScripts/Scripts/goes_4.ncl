;----------------------------------------------------------------------
; goes_4.ncl
;
; Concepts illustrated:
;   - Basically... same as goes_2.ncl
;   - Reading a GOES-VIS file
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
   fili = "goes12_1_2011_094_1815.BRIT.VIS.nc"
   f    = addfile(diri+fili,"r")
   d    = f->data          ; float data(time, yc, xc) ;
                           ; data:type = "VISR" ;
   d@_FillValue = 255.0

   printVarSummary(d)
   print("d: min="+min(d)+"   max="+max(d))
    
;*********************************
; Fix the variable so it has recognizable missing data
;*********************************
   lat2d  = f->lat
   lon2d  = f->lon
   print("lat2d: min="+min(lat2d)+"   max="+max(lat2d))
   print("lon2d: min="+min(lon2d)+"   max="+max(lon2d))

print(lat2d(10,:)+"   "+lon2d(10,:))

   if (any(abs(lat2d).gt.90.0) .or. any(abs(lon2d).gt.360.0) ) then
       print("lat2d and/or lon2d may have bogus values")
       print("@lat2d/@lon2d will likely not work")
       exit
   end if
                           ; associate coordinates with variable
   d@lat2d = lat2d         ; (yc, xc)
   d@lon2d = lon2d         
   
   crTime  = f->crTime     ; assorted info
   crDate  = f->crDate
   lineRes = f->lineRes
   elemRes = f->elemRes
   print("crTime ="+crTime +"    crDate ="+crDate)
   print("lineRes="+lineRes+"    elemRes="+elemRes)

;*********************************
; create plot
;*********************************
   fNameBase = str_get_field(fili,1,".") + str_get_field(fili,2,".")

  ;pltName = fNameBase
   pltName = "goes"

   pltType = "png"                              ; "ps", "eps", "pdf", "png","x11"
   pltDir  = "./"

   wks = gsn_open_wks(pltType, pltDir+pltName) 

   res                     = True
   res@cnFillOn            = True            ; turn on color
   res@cnFillPalette       = "BlAqGrYeOrReVi200" ; set color map
   res@cnFillMode          = "RasterFill"    ; cell mode
   res@cnLinesOn           = False           ; Turn off contour lines

   res@gsnAddCyclic        = False           ; data not cyclic
   res@gsnMaximize         = True            ; ps, pdf, pdf    
   res@pmTickMarkDisplayMode = "Always"      ; use NCL default 
  ;res@lbOrientation       = "Vertical"      ; vertical label bar

   res@mpMinLatF           = min(lat2d)    ; region to zoom in on
   res@mpMaxLatF           = max(lat2d)
   res@mpMinLonF           = min(lon2d)
   res@mpMaxLonF           = max(lon2d)
   res@mpFillOn            = False
  ;res@mpOutlineBoundarySets = "USStates"    ; turn on state boundaries
  ;res@mpOutlineBoundarySets = "AllBoundaries"
   res@mpOutlineBoundarySets = "National"    ; turn on country boundaries

  ;res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
                                                ; arrays have missing values.

   res@gsnLeftString       = d@type
   res@tiMainString        = fili
print(res)
   nt   = 0
   plot = gsn_csm_contour_map(wks,d(nt,:,:), res)

