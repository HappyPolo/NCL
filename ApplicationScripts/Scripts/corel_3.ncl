;*************************************************
; corel_3.ncl
;
; Concepts illustrated:
;   - Calculating a two-dimensional correlation in time
;   - Reordering an array
;   - Copying attributes from one variable to another
;   - Copying coordinate arrays from one variable to another
;   - Removing the end boxes in a labelbar
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;************************************************
; open file and read in variable
;***********************************************
  in1  = addfile("b003_TS_200-299.nc","r")
  in2  = addfile("b006_TS_035-134.nc","r")
  
  tmp1 = in1->TS
  tmp2 = in2->TS
;************************************************
; reorder to get time as right most dimension
;***********************************************
  ts1 = tmp1(lat|:,lon|:,time|:)
  ts2 = tmp2(lat|:,lon|:,time|:)
;************************************************
; calculate cross correlations
;************************************************
  maxlag = 2                                    ; set lag
; note, the max lag should not be more than N/4
  
  ccr = esccr(ts1,ts2,maxlag)                   ; calc cross correlations

; copy meta data and coordinate variables using contributed functions
  copy_VarAtts(ts1, ccr)                    
  copy_VarCoords_1(ts2,ccr)
;************************************************
; plot the correlations
;************************************************
  wks  = gsn_open_wks("png","corel")             ; send graphics to PNG file
 
  res                      = True                ; make plot mods

  res@cnFillOn             = True                ; turn on color
  res@cnFillPalette        = "BlWhRe"            ; set color map

  res@cnLinesOn            = False               ; turn off contour lines
  res@cnLevelSelectionMode = "ManualLevels"      ; manually set cn levels
  res@cnMinLevelValF       = -1.                 ; min level
  res@cnMaxLevelValF       =  1.                 ; max level
  res@cnLevelSpacingF      = .1                  ; contour level spacing

  res@cnLabelBarEndStyle   = "ExcludeOuterBoxes" ; remove the two end boxes from the labelbar
  res@pmLabelBarWidthF     = 0.8

  lag                      = 0
  res@tiMainString         = "Correlations at lag "+lag
  plot = gsn_csm_contour_map(wks,ccr(:,:,lag),res) 
;************************************************
end






	
