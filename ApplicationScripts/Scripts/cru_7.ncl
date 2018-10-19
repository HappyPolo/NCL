;*****************************************************
; cru_7.ncl
;
; Concepts illustrated:
;   - Plotting CRU (Climate Research Unit) data
;   - Converting "short" data to "float"
;   - Paneling six plots on a page with a common labelbar
;   - Redefining the time coordinate array of a variable
;   - Drawing raster contours
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;***************************************************
; Specify user desired yyyymm to be plotted
;***************************************************
  YYYYMM = (/190101,190107,198001,198007,200201,200207/)

;***************************************************
; Read temperature anomalies
; data are stored as type "short" ... convert to float
; The degenerate 'unspecified' dimension is eliminated
;***************************************************
  fili   = "CRU_scpdsi_europe.nc"
  f      = addfile(fili,"r")
  x      = short2flt(f->scPDSI)            ; (time, lat, lon)
  
  print("PDSI: min="+min(x)+"  max="+max(x))

;***************************************
; Replace the input time coordinate with the yyyymm
;***************************************  
  x&time = f->yyyymm

;***************************************
; create plot
;***************************************  
  wks = gsn_open_wks("png","cru")            ; send graphics to PNG file

  plot= new (dimsizes(YYYYMM), graphic)      ; create graphical array
  
  res                      = True            ; plot mods desired
  res@gsnDraw              = False           ; don't draw yet 
  res@gsnFrame             = False           ; don't advance frame yet 

  res@cnFillOn             = True            ; color contours
  res@cnFillPalette        = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn            = False           ; turn off contour lines
  res@cnFillMode           = "RasterFill"    ; Raster Mode

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = 0.5                ; set min contour level
  res@cnMaxLevelValF       = 3.0                ; set max contour level
  res@cnLevelSpacingF      = 0.25               ; set contour spacing

  res@lbLabelBarOn         = False           ; turn off individual lb's
  
  res@gsnAddCyclic         = False           ; regional grid so not cyclic
  res@mpMinLatF            = min(x&lat)
  res@mpMaxLatF            = max(x&lat)
  res@mpMinLonF            = min(x&lon)
  res@mpMaxLonF            = max(x&lon)

  do nt = 0,dimsizes(YYYYMM)-1
     res@gsnLeftString   = "scPDSI"                      
     res@gsnCenterString = YYYYMM(nt)
     plot(nt) = gsn_csm_contour_map(wks,x({YYYYMM(nt)},:,:),res)
  end do
;************************************************
; create panel plot
;************************************************

  resP                  = True                   ; modify the panel plot
  resP@txString         = fili                   ; plot title
  resP@gsnMaximize      = True                   ; make ps, eps, pdf, ... large
  resP@gsnPanelLabelBar = True                   ; add common label bar
  gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

