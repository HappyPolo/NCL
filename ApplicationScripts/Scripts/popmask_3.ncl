;***********************************************
; popmask_3.ncl
;
; Concepts illustrated:
;   - Using builtin functions to minimize computational load
;   - Selecting nearest gridpoint of POP file to a target grid point
;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

;************************************************
; Create target grid. Here a rectilinear grid.
;************************************************
  keyi = "SODA"
  diri = "/Users/shea/Data/SODA/"
  fili = "SODA_2.2.4_201012.cdf"
  fi   = addfile(diri+fili, "r")
  lat  = fi->LAT
  lon  = fi->LON

  nlat = dimsizes(lat)
  mlon = dimsizes(lon)

  msg  = -999
  pmsk = new ( (/nlat,mlon/), "integer", msg)
  pmsk!0   = "lat"
  pmsk!1   = "lon"
  pmsk&lat =  lat
  pmsk&lon =  lon

  
;************************************************
; Read POP variables
;************************************************
 ;diri  = "./"
 ;fili  = "gx1v3.210.pop.h.0001-01.nc"
  diri  = "/Users/shea/Data/POP/"
  fili  = "gx1v3.pop.h.REGION_MASK.nc"
  pathi = diri+fili
  fin   = addfile(pathi,"r")
  rmask = fin->REGION_MASK        ; (384,320)
  lat2d = fin->TLAT               ;     "
  lon2d = fin->TLONG              ;     "

  dim2d = dimsizes(lat2d)         ; POP grid size
  jlat  = dim2d(0)                ; 384
  ilon  = dim2d(1)                ; 320

  printVarSummary(rmask)
  printMinMax(rmask, True)       ; -14 ==> 11
  printVarSummary(lat2d)
  printMinMax(lat2d, True)  
  
;************************************************
; Operations to improve speed:
;************************************************

  jlat2d = conform_dims( dim2d, ispan(0,jlat-1,1), 0)
  ilon2d = conform_dims( dim2d, ispan(0,ilon-1,1), 1)
  
  rmask_1d  = ndtooned(rmask)
  lat2d_1d  = ndtooned(lat2d)
  lon2d_1d  = ndtooned(lon2d)
  jlat2d_1d = ndtooned(jlat2d)
  ilon2d_1d = ndtooned(ilon2d)
  kpop_1d   = dimsizes(rmask_1d)   ; 384*320
 
;************************************************
; Closest POP mask value to target grid
; (a) loop over target grid 
; (b) for each target latitude; get subset indexes
; (c) calculate great circle distances for subset of data
; (d) ascertain the correct POP grid mask and assign
;************************************************
  wcStrt = systemfunc("date")
  
  latbuf = 3.0  ; arbitrary

  do nl=0,nlat-1
     latlo = lat(nl)-latbuf     ; latitude bound
     lathi = lat(nl)+latbuf
     kk    = ind(lat2d_1d.gt.latlo .and. lat2d_1d.lt.lathi)
     if (.not.ismissing(kk(0))) then
     
         do ml=0,mlon-1        
            gcdist = gc_latlon(lat(nl),lon(ml), lat2d_1d(kk),lon2d_1d(kk), 2, 2)
            if (.not.ismissing(gcdist(0))) then
                jlkk  = jlat2d_1d(kk)
  	        ilkk  = ilon2d_1d(kk)
                kkmin = minind(gcdist)
	        jl    = jlkk(kkmin)
	        il    = ilkk(kkmin)
                pmsk(nl,ml) = (/ rmask(jl,il) /) 
		delete([/jlkk,ilkk,kkmin/])
            end if          ; (.not.ismissing(gcdist(0)))
	    delete(gcdist)
         end do             ; ml loop
 
     end if                 ; (.not.ismissing(kk(0)))
     delete(kk)
  end do                    ; nl loop

  printVarSummary(pmsk)

  wallClockElapseTime(wcStrt, "Mask Creation: "+keyi, 0)
;************************************************
; Write netCDF
;************************************************
  diro  = "./" 
  filo  = "popMask."+keyi+"_"+nlat+"x"+mlon+".nc"
  patho = diro+filo
  system("/bin/rm -f "+patho)
  ncdf  = addfile(patho, "c")

  ncAtts= True
  ncAtts@title = "POP Mask at "+nlat+"x"+mlon+": "+keyi
  ncAtts@pop_source    = fili 
  ncAtts@pop_grid      = "nlat="+jlat+";  nlon="+ilon  
  ncAtts@creation_date = systemfunc("date")
  fileattdef( ncdf, ncAtts ) 

  pmsk@long_name = rmask@long_name

  ncdf->GMASK  = pmsk

;************************************************
; create plot
;************************************************
  plot = new (2, "graphic")
  
;;wks = gsn_open_wks("ps","Mask_"+keyi)  
  wks = gsn_open_wks("png","popmask")
  gsn_define_colormap(wks, "amwg")  

  res                  = True                ; plot mods desired
  res@gsnFrame         = False
  res@gsnDraw          = False
  res@gsnAddCyclic     = True 

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        =  False             ; Turn off contour lines
  res@cnLineLabelsOn   =  False
  res@cnLevelSelectionMode = "ExplicitLevels" 
  res@cnLevels         =   (/ -13,-12,-5,0,1,2,3,4,5,6,7,8,9,10,11/)
 
  res@lbLabelBarOn     = False              ; turn off individual lb's

  res@mpCenterLonF     = 205                ; set map center
  res@mpFillOn         = False

  res@gsnLeftString    = "Selected Basins"        

  rmask@lat2d   = lat2d
  rmask@lon2d   = lon2d

  res@tiMainString     = "POP: Basin Index Values"
  plot(0) = gsn_csm_contour_map_ce(wks, rmask, res) ; create plot

  res@tiMainString     = keyi+": "+nlat+"x"+mlon+": Basin Index Values"
  plot(1) = gsn_csm_contour_map_ce(wks, pmsk, res) ; create plot
  
  resP                  = True                   ; modify the panel plot
  resP@gsnMaximize      = True
  resP@gsnPanelLabelBar = True                   ; add common colorbar
 ;resP@txString         = "A common title"       ; add common title
 ;resP@pmLabelBarHeightF=  0.100
 ;resP@pmLabelBarWidthF =  0.80              ; default is 0.6
  resP@lbLabelPosition  = "Center"           ; label position
  resP@lbLabelAlignment = "BoxCenters"       ; label orientation
 ;resP@lbLabelStrings    = ""+ res@cnLevels   ; trick 
  resP@lbLabelStrings    = ""+ (/ -14,-13,-12,-5,0,1,2,3,4,5,6,7,8,9,10,11/)


  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

