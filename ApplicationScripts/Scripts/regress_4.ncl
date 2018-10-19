;*************************************************
; regress_4.ncl
;
; Concepts illustrated:
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Calculating the regression coefficient (slope) at each grid point   
;   - Copying attributes from one variable to another
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;************************************************
; Specify geographical region and time span (year-month start and end
;************************************************

  latS     = -90               
  latN     =  90
  lonL     =   0
  lonR     = 360

  ymStrt   = 195101     
  ymLast   = 201012
  
  pltTitle = "Globe: "+(ymStrt/100)+"-"+(ymLast/100)

;************************************************
; Read from netCDF file: variable is type short...unpack
;************************************************
   diri   = "./"
   fili   = "air.sig995.mon.mean.nc"
   f      = addfile(diri+fili,"r") 

   YYYYMM = cd_calendar( f->time, -1)

   iStrt  = ind(YYYYMM.eq.ymStrt)
   iLast  = ind(YYYYMM.eq.ymLast)

   x      = short2flt( f->air(iStrt:iLast,{latS:latN},{lonL:lonR}) )

   x      = x-273.15
   x@units= "degC"

   printVarSummary(x)                            ; [time| 720]x[lat| 91]x[lon| 180]

   yyyymm = cd_calendar(x&time, -1)
   yyyy   = yyyymm/100

   dimx = dimsizes(x)
   ntim = dimx(0)                ; all years and months
   nlat = dimx(1)
   mlon = dimx(2)

   year  = ispan(yyyy(0), yyyy(ntim-1), 1)
   nyrs  = dimsizes(year)

;************************************************
; Areal averages: cos(lat) is good enough
;************************************************

   xann  = month_to_annual(x , 1)                 ; [year| 60]x[lat| 91]x[lon| 180]
   xann&year  = year
   printVarSummary(xann)

;************************************************
; Calculate the regression coefficients (slopes)    
;************************************************
   rc           = regCoef(year,xann(lat|:,lon|:,year|:))            
   
   rc@long_name = "Trend"
   rc@units     = xann@units+"/year"
   copy_VarCoords(xann(0,:,:), rc)                ; copy lat,lon coords

   printVarSummary(rc)

;************************************************
; for illustration: change units to degC/period-used
;************************************************
   rc           = rc*nyrs                       ; (C/year)*(nyrs)
   rc@units     = "degC/"+nyrs+"_year"

;************************************************
; plotting parameters 
;************************************************
   wks  = gsn_open_wks("png","regress")         ; send graphics to PNG file
   
   res                       = True     
   res@gsnMaximize           = True             ; make large

   res@cnFillOn              = True             ; turn on color
   res@cnLinesOn             = False            ; turn off contour lines
   res@cnLineLabelsOn        = False            ; turn off contour line labels
 ;;res@cnFillMode            = "RasterFill"

   res@cnLevelSelectionMode  = "ManualLevels"   ; set manual contour levels
   res@cnMinLevelValF        =  -2.0            ; set min contour level
   res@cnMaxLevelValF        =   2.0            ; set max contour level
   res@cnLevelSpacingF       =   0.2            ; set contour interval

   res@mpFillOn              = False            ; turn off default background gray
  ;res@mpCenterLonF          = 180

   res@gsnCenterString       = year(0)+"-"+year(nyrs-1) 
   
   res@tiMainString          = "20th Century Reanalysis: sig995"    ; fili
   plot = gsn_csm_contour_map_ce(wks,rc,res)    
  end
