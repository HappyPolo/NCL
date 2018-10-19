; The variables on this file are expressed as complex coefficients
;     (time,lev, real_imaginary ,kat,lon) => (44,31 2 ,160,360)
; ---
; Normally, the there would be 160x160 complex coefficients.
; However the coefficients were truncated at Tnwmx (107 values including
; the constant). NCL's shsgc is expecting the full array size. 
; ---

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

   nlat = 160
   mlon = 2*nlat
   nwmx = 106                       ; truncation wave
  
   diri = "/project/cas/shea/GRIB/" ; input directory
   fili = "Y42677.cc.grb"           ; input file(s)
   f    = addfile(diri+fili, "r")   ; reference the file

                                    ; there are NO lat/lon/plev on file
                                    ; manually create
   lat  = latGau(nlat, "lat", "latitude", "degrees_north")
   lon  = lonGlobeF(mlon, "lon", "longitude", "degrees_east")

   hyam = f->lv_HYBL1_a     ; read from a file the mid-layer coef
   hybm = f->lv_HYBL1_b     ; read from a file
   lev  = 1000*(hyam+hybm)
   lev@units = "hPa"
   lev@long_name = "Nominal Pressure level"
   lev!0= "lev"
   lev&lev = lev 

   work = f->D_GDS50_HYBL           ; (44,31, 2 ,160,360)
   printVarSummary(work)            ;  0  1   2   3   4
  
   dimw = dimsizes(work)
   ntim = dimw(0)
   klev = dimw(1)
                                    ; preallocate FULL coef size
   a    = new( (/ntim,klev,nlat,nlat/), float, getFillValue(work))
   b    = new( (/ntim,klev,nlat,nlat/), float, getFillValue(work))
   a    = 0.0                       ; init to 0.0
   b    = 0.0
                                           ; place into proper locations
   a(:,:,0:nwmx,0:nwmx) = work(:,:,0,:,:)  ; real
   b(:,:,0:nwmx,0:nwmx) = work(:,:,1,:,:)  ; imaginary
  
   div = new( (/ntim,klev,nlat,mlon/),float,getFillValue(work))
   shsgc(a,b,div)
                                    ; manually assign meta data
   div@long_name = work@long_name
   div@units     = work@units   
   
   div!0    = "time"
   div!1    = "lev"
   div!2    = "lat"
   div!3    = "lon"
   div&time =  work&initial_time0_hours
   div&lev  =  lev
   div&lat  =  lat
   div&lon  =  lon
  
   printVarSummary(div)
   printMinMax(div,0)

  div       = div*1e6                           ; scale for nicer plots
  div@units = "1e6*"+div@units                  ; not a lot of 0s

  date      = cd_calendar(div&time, -3)         ; yyyymmddhh

;*************************************************
; plot results
;*************************************************    

  wks  = gsn_open_wks("ps","cmplxgrb") 
 ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; choose colormap
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")  ; choose colormap

  res                      = True
  res@gsnMaximize          = True               ; make ps, eps, pdf, large

;---This resource not needed in NCL V6.1.0
  res@gsnSpreadColors      = True               ; Use all colors

  res@gsnPaperOrientation  = "portrait"
  res@cnFillOn             = True               ; color on
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off line labels
  res@mpFillOn             = False
  res@lbLabelAutoStride    = True

  nt   = 0
  plvl = 300                                    ; pick closest level

  res@tiMainString         = "Derived from Spherical Harmonic Coefficients"
  res@gsnCenterString      = date(nt)+"    "+toint(lev({plvl}))+lev@units

; automatically create nice symmetric min/max/ci values 
;;symMinMaxPlt (div(nt,{plvl},:,:),20,False,res)  

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -50.               ; set min contour level
  res@cnMaxLevelValF       =  50.               ; set max contour level
  res@cnLevelSpacingF      =   5.               ; set contour spacing

  plot=gsn_csm_contour_map_ce(wks,div(nt,{plvl},:,:),res)
end
