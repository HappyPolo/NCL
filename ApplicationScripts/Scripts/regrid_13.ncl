;*************************************************************
; regrid_13.ncl
;
; Concepts illustrated:
;   - Interpolating from a fixed grid to a lower resolution using conservative remapping
;   - Computing dispersion statistics
;   - Isolating the Tibetan Plateau
;   - Outlining a map region
;   - Drawing a cylindrical equidistant map
;   - Creating a netCDF file
;*************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  zcrit = 1500  ; user specifed elevation boundary for Tibet 

  latS  = 25    ; rough box that encloses the Tibet Plateau
  latN  = 42    ; this is larger than the 'final' Tibet region
  lonW  = 72    ; common TIBET region: 28N-40N and 75-104E
  lonE  = 108

  netCDF= True

;*********************************************
; Read global grid   [180W to 180E]
; ELEV: [LAT | 5401] x [LON | 10801] *includes* cyclic pt
;*********************************************
  diri  = "./"
  fili  = "ETOPO2_GLOBAL_2_ELEVATION.nc"   ; NGDC
  f     = addfile(diri+fili,"r")
  Z     = short2flt( f->ELEV(:,0:10799) )  ; Do not read the cyclic pt

  printVarSummary(Z)             ; Z: min=-10654   max=8593

  title = Z@long_name
  delete(Z@long_name)            ; do not want on panel plot
  delete(Z@units)

;*********************************************
; areal average conservative remapping
;*********************************************

  NLATR = 360       ; 0.5 x 0.5
  MLONR = 720

  LATR  = latGlobeFo(NLATR, "LATR", "latitude" , "degrees_north")
  LONR  = lonGlobeFo(MLONR, "LONR", "longitude", "degrees_east")   ; 0-360
  LONR  = (/LONR-180/)    ; -180 to 180
  LONR&LONR = LONR

  ZR    = area_conserve_remap_Wrap (Z&LON,Z&LAT,Z, LONR,LATR, False)  ; 5.2.0
 ;ZR    = area_hi2lores_Wrap (Z&LON,Z&LAT,Z, True, 1.0, LONR,LATR, False)  ; 5.1.0

  printVarSummary(ZR)            ; ZR (1x1): min=-10439.7   max=5713.99

;*********************************************
; Extract the Tibet region stats from the original and interpolated grids
;*********************************************

  ztibet = Z({latS:latN}, {lonW:lonE}) 
  printVarSummary(ztibet)
  printMinMax(ZR, True)
 
  ztibetr= ZR({latS:latN}, {lonW:lonE}) 
  printVarSummary(ztibetr)
  printMinMax(ztibetr, True)

  opt    = True
  opt@PrintStat = True
  stat   = stat_dispersion(ztibet , opt )
  statR  = stat_dispersion(ztibetr, opt )

;*********************************************
; Set all elevations .lt. zcrit to _FillValue
;*********************************************

  ztibet = where(ztibet .lt.zcrit, ztibet@_FillValue , ztibet )
  ztibetr= where(ztibetr.lt.zcrit, ztibetr@_FillValue, ztibetr)

;*********************************************
; Plot
;*********************************************

  wks = gsn_open_wks ("png", "ESMF_regrid")             ; send graphics to PNG file

  res                             = True
  res@gsnDraw                     = False
  res@gsnFrame                    = False
  res@gsnAddCyclic                = False  ; region only

  res@cnFillMode                  = "RasterFill"      
  res@cnLinesOn                   = False  ; Turn off contour lines
  res@cnLineLabelsOn              = False  ; Turn off contour labels
  res@cnFillOn                    = True   ; Turn on contour fill
  res@cnFillPalette               = "BlAqGrYeOrReVi200"

  res@cnLevelSelectionMode        = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF              = zcrit              ; set min contour level
  res@cnMaxLevelValF              = 5750               ; set max contour level
  res@cnLevelSpacingF             =  250 

  res@lbLabelBarOn                = False

  res@mpMinLatF                   = latS
  res@mpMaxLatF                   = latN    
  res@mpMinLonF                   = lonW
  res@mpMaxLonF                   = lonE     
  res@mpCenterLonF                = (lonW+lonE)*0.5
  res@mpFillOn                    = False

  plot    = new (2, "graphic")
  plot(0) = gsn_csm_contour_map(wks,ztibet , res)
  plot(1) = gsn_csm_contour_map(wks,ztibetr, res)

  resP = True
  resP@gsnMaximize         = True       ; make ps/eps/pdf large [no effect x11]
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@gsnPanelMainString  = title+": Tibet: "+zcrit

  gsn_panel(wks,plot,(/2,1/),resP)

;*******************************************************
; Mask more of the region 
;*******************************************************

  latS   = 28    ; commonly used TIBET boundaries
  latN   = 40    
  lonW   = 75
  lonE   = 104
                 ; mask out more area ... isolate Tibet Plateau
  lat2dr = conform(ztibetr, ztibetr&LATR, 0) 
  lon2dr = conform(ztibetr, ztibetr&LONR, 1) 
  ztibetr= where(lat2dr.lt.latS .or. lat2dr.gt.latN .or. \
                 lon2dr.lt.lonW .or. lon2dr.gt.lonE      \
                ,ztibetr@_FillValue, ztibetr)

;*******************************************************
; Create a crude TIBET outline [outer boundary]
;*******************************************************

  k      = -1
  mlonr  = dimsizes( ztibetr&LONR )
  lonlo  = new ( mlonr, typeof(ztibetr&LONR),"No_FillValue")
  latlo  = lonlo
  lonup  = lonlo
  latup  = lonlo

  do ml=0,mlonr-1           ; just outer boundary
     nl = ind(.not.ismissing(ztibetr(:,ml)))
     if (.not.ismissing(nl(0))) then
         N = dimsizes(nl)
         k = k+1
         latlo(k) = ztibetr&LATR(nl(0))      ; low boundary
         lonlo(k) = ztibetr&LONR(ml) 
         latup(k) = ztibetr&LATR(nl(N-1))    ; up  boundary
         lonup(k) = ztibetr&LONR(ml) 
         print(k+"  "+latlo(k)+"  "+lonlo(k) +"  "+latup(k)+"  "+lonup(k))
     else
         print("No eligible pts: "+ztibetr&LONR(ml))
     end if
     delete(nl)     ; may change the next iteration
  end do

  K    = 2*k+1      ; total pts
  TLAT = new ( K, typeof(latlo), "No_FillValue")
  TLON = new ( K, typeof(latlo), "No_FillValue")

  TLAT(0:k-1) = latlo(0:k-1)
  TLON(0:k-1) = lonlo(0:k-1)
  TLAT(k:K-2) = latup(k-1:0)     ; reverse the path
  TLON(k:K-2) = lonup(k-1:0)
  TLAT(K-1)   = latlo(0)         ; complete the path
  TLON(K-1)   = lonlo(0)          
  print(TLAT+"   "+TLON)

  TLAT@units  = "degrees_north"  ; needed for georeferenced plot
  TLON@units  = "degrees_east"

  res@gsnDraw      = True 
  res@gsnMaximize  = True       ; make ps/eps/pdf large [no effect x11]
  res@gsnPaperOrientation = "portrait"
  res@lbLabelBarOn = True  

  gsRes  = True
  gsRes@gsLineThicknessF = 7.0

  res@gsnCenterString    = "Tibet Boundary Outline"
  plt    = gsn_csm_contour_map(wks,ztibet , res)
  gsn_polyline(wks,plt,TLON,TLAT,gsRes)
  frame(wks)

;;plt    = gsn_csm_contour_map(wks,ztibetr, res)
;;gsn_polyline(wks,plt,TLON,TLAT,gsRes)
;;frame(wks)

;*******************************************************
; netCDF
;*******************************************************

  if (netCDF) then
       TLAT!0 = "pts"
       TLON!0 = "pts"
       TLAT@long_name = "latitude: TIBET BOUNDARY: zcrit="+zcrit
       TLON@long_name = "longitude: TIBET BOUNDARY: zcrit="+zcrit
     
       diro   = "./"
       filo   = "Tibet_Plateau_ETOPO2_"+zcrit+".nc"
       system("/bin/rm -f "+diro+filo)       ; remove any pre-existing file
       ncdf   = addfile(diro+filo ,"c")      ; open output netCDF file
       ncdf@title  = "Tibetan Plateau Outer Boundary"
       ncdf@source = f@source
       ncdf@creation_ate = systemfunc("date")

       ncdf->TLON  = TLON
       ncdf->TLAT  = TLAT
  end if
end

