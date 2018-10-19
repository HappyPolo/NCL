;**************************************************
; skewt_6.ncl
;
; Concepts illustrated:
;   - Reading RUC (Rapid Update Cycle)  GRIB data
;   - Using getind_latlon2d to determine grid locations
;   - Drawing Skew-T plots at nearest grid locations  
;                    to user specified locations
;**************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
;***********************************************
; RUC Data downloaded from:
;     http://nomads.ncdc.noaa.gov/data.php?name=access#hires_weather_datasets
; RUC-ANL: http
;     Specifically: http://nomads.ncdc.noaa.gov/data/rucanl/201205/20120501/
;***********************************************
; The GRIB file's contents can be examined via:
;     ncl_filedump -itime ruc2anl_130_20120501_0000_000.grb2  | less
;***********************************************
 begin

; --- Read RUC GRIB file------------;
  diri  = "./"
  fili  = "ruc2anl_130_20120501_0000_000.grb2"

                                    ; force a 'time' dimension
  setfileoption("grb","SingleElementDimensions","Initial_time")

  f     = addfile(diri+fili,"r")
  p     = f->lv_ISBL0               ;  ( lv_ISBL0 )
  time  = f->initial_time0_encoded  ; yyyymmddhh.hh_frac

                                    ; RUC grid point locations
  lat2d = f->gridlat_0              ; ( ygrid_0, xgrid_0 ) 
  lon2d = f->gridlon_0
  print("lat2d: min="+min(lat2d)+"  ;  max="+max(lat2d))
  print("lon2d: min="+min(lon2d)+"  ;  max="+max(lon2d))

  p     = p*0.01                    ; change units
  p@units = "hPa"                   ; skewT, mixhum_ptrh use mb (hPa)

; --- Specify one or more locations

  lat   = (/ 25    , 50.781 /)   
  lon   = (/-120.3 ,-75.2   /)   
  npts  = dimsizes(lat)

;*************************
; create plot(s)
;*************************

  skewtOpts                 = True
  skewtOpts@DrawColAreaFill = True    ; default is False
   
  dataOpts   = True
  dataOpts@PrintZ = True

  do n=0,npts-1           ; loop over each grid pt

         ; find grid point nearest the user specified location
     nm  = getind_latlon2d (lat2d,lon2d, lat(n), lon(n))
     nn  = nm(0,0)
     mm  = nm(0,1)
     print("location=("+lat(n)+","+lon(n)+")  grid=("+lat2d(nn,mm)+","+lon2d(nn,mm)+")")

                            
     tk   = f->TMP_P0_L100_GLC0(0,:,nn,mm)
     z    = f->HGT_P0_L100_GLC0(0,:,nn,mm)
     rh   = f->RH_P0_L100_GLC0(0,:,nn,mm)
     u    = f->UGRD_P0_L100_GLC0(0,:,nn,mm)
     v    = f->VGRD_P0_L100_GLC0(0,:,nn,mm)

         ; change units and calculate needed variables
     tc   = tk - 273.15
     tc@units= "degC"            

     q    = mixhum_ptrh (p, tk, rh, 2)
     q@units = "kg/kg"

     tdc  = dewtemp_trh(tk,rh) - 273.15 
     tdc@units = "degC"            

     wspd = sqrt(u^2 + v^2)
     wdir = wind_direction(u,v,0)

     itime= toint(time)
     skewtOpts@tiMainString    = "RUC: "+itime+": ("+lat(n)+","+lon(n)+")"

          ; each location will have a different file name      
     wks  = gsn_open_wks ("png", "ruc2anl_skewt_"+itime+"_"+sprinti("%0.3i",n))
     skewt_bkgd = skewT_BackGround (wks, skewtOpts)
     skewt_data = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                       , wspd,wdir, dataOpts)
     draw (skewt_bkgd)
     draw (skewt_data)
     frame(wks)
  end do

 end
