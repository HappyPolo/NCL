;*************************************************
; regress_2.ncl
;
; Concepts illustrated:
;   - Calculating the regression coefficient (slope) at each grid point   
;   - Copying attributes from one variable to another
;   - Drawing color-filled contours over a cylindrical equidistant map
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;************************************************
; create pointer to file and read in temperature
;************************************************
   diri = "./"
   fili = "b40.20th.track1.2deg.001.cam2.h0.PSL.1850-01_cat_2005-12.nc"
   in  = addfile(diri+fili,"r") 

   tmp  = in->PSL 
   ts   = tmp(lat|:,lon|:,time|:)               ; reorder variable

   delete(tmp)                                  ; no longer needed

;************************************************
; create x and calculate the regression coefficients (slopes, trends)    
;************************************************
   time         = ts&time                       ; days since 1850-01-01
   rc           = regCoef(time,ts)             
   
   rc@long_name = "regression coefficient (trend)"
   rc@units     = ts@units+"/day"    
   copy_VarCoords(ts(:,:,0), rc)                ; copy lat,lon coords

;************************************************
; for illustration: change units to Pa/year
;************************************************

   rc           = rc*365                   ; (Pa/day)*(365_day/year)
   rc@units     = "Pa/year"

;************************************************
; plotting parameters 
;************************************************
   wks  = gsn_open_wks("png", "regress")        ; send graphics to PNG file
   
   res                       = True     
   res@gsnMaximize           = True             ; make large

   res@cnFillOn              = True             ; turn on color
   res@cnFillPalette         = "ViBlGrWhYeOrRe" ; set color map
   res@cnLinesOn             = False            ; turn off contour lines
   res@cnLineLabelsOn        = False            ; turn off contour line labels
 ;;res@cnFillMode            = "RasterFill"

   res@cnLevelSelectionMode  = "ManualLevels"   ; set manual contour levels
   res@cnMinLevelValF        =  -1.00           ; set min contour level
   res@cnMaxLevelValF        =   1.00           ; set max contour level
   res@cnLevelSpacingF       =   0.10           ; set contour interval

   res@mpFillOn              = False            ; turn off default background gray
   res@mpCenterLonF          = 210
   
   res@tiMainString          = fili
   plot = gsn_csm_contour_map_ce(wks,rc,res)    
  end
