;*************************************************
; conOncon_2.ncl
;
; Concepts illustrated:
;   - Overlaying two sets of contours on a map
;   - Drawing negative contour lines as dashed lines
;   - Drawing the zero contour line thicker
;   - Changing the center longitude for a cylindrical equidistant projection
;   - Using a blue-white-red color map
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; open netCDF file
;************************************************
  a = addfile("sst8292a.nc","r")
  b = addfile("olr7991a.nc","r")
;************************************************
; Read in Sea Surface Temperature Anomalies
; Read in OLR Anomalies
; Determine the subscripts corresponding to Dec 82
;************************************************
  sst      = a->SSTA
  olr      = b->OLRA
  date_sst = a->date
  date_olr = b->date
  ind_sst  = ind(date_sst.eq.198212)
  ind_olr  = ind(date_olr.eq.198212)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","conOncon")            ; send graphics to PNG file

;************************************************
; resource list for first data array
;************************************************
  res1                      = True
  res1@gsnDraw              = False              ; don't draw
  res1@gsnFrame             = False              ; don't advance frame

  res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res1@cnMinLevelValF       = -5.                ; set min contour level
  res1@cnMaxLevelValF       =  5.                ; set max contour level
  res1@cnLevelSpacingF      =  0.5               ; set contour spacing
  res1@cnFillPalette        = "BlWhRe"           ; set color map for sst

  res1@lbOrientation        = "Vertical"         ; vertical label bar

  res1@mpCenterLonF         = 180.               ; center plot at 180
  res1@mpMinLonF            = 100.               ; select a subregion
  res1@mpMaxLonF            = 300.
  res1@mpMinLatF            = -60. 
  res1@mpMaxLatF            =  60.

  res1@cnFillDrawOrder  = "Predraw"             ; areas before map gets

  res1@gsnCenterString  = "December 1982"       ; some titles 
  res1@gsnLeftString    = "degC" 
  res1@gsnRightString   = "(W m s~S~-2~N~)"     ; "~" is txFuncCode

;************************************************
; resource list for second data array
;************************************************
  res2                      = True
  res2@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res2@cnMinLevelValF       = -80.              ; set min contour level
  res2@cnMaxLevelValF       =  40.              ; set max contour level
  res2@cnLevelSpacingF      =  10.              ; set contour spacing
  res2@cnLineLabelsOn       = True
  res2@gsnContourZeroLineThicknessF = 2. 	; doubles thickness of zero contour
  res2@gsnContourNegLineDashPattern = 1 	; sets negative contours to dash pattern 1

  plot = gsn_csm_contour_map_overlay(wks,sst(ind_sst,:,:),\
                                     olr(ind_olr,:,:),res1,res2)
  draw(plot)
  frame(wks)				     
end
