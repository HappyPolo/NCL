;----------------------------------------------------------------------
; contoursym_1.ncl
;
; Concepts illustrated:
;   - Using a symmetric color map
;   - Using a blue-red color map
;   - Explicitly setting contour levels
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
;---Open file and read in Sea Surface Temperature Anomalies
  a   = addfile("sst8292a.nc","r")
  sst = a->SSTA

;---Start the graphics
  wks = gsn_open_wks("png","contoursym")         ; send graphics to PNG file

  res                      = True

  res@gsnMaximize          = True               ; maximize plot in frame

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -5.                ; set min contour level
  res@cnMaxLevelValF       =  5.                ; set max contour level
  res@cnLevelSpacingF      =  0.5               ; set contour spacing
 
  res@cnFillOn             = True               ; turn on contour fill
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour labels

  res@cnFillPalette        = "BlueRed"          ; set color map

  plot = gsn_csm_contour_map(wks,sst(0,:,:),res)
end
