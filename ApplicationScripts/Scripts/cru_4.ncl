;*****************************************************
; cru_4.ncl
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
begin
;***************************************************
; Specify user desired yyyymm to be plotted
;***************************************************
  yyyymm = (/185101,185107,195001,195007,201001,201007/)

;***************************************************
; Read temperature anomalies
; data are stored as type "short" ... convert to float
; The degenerate 'unspecified' dimension is eliminated
;***************************************************
  fili   = "CRUTEM4v.nc"
  f      = addfile(fili,"r")
  T_anom = f->temp(:,0,:,:)      ; temp(t, unspecified, latitude, longitude)
                                 ; T_anom(t, latitude, longitude)

;***************************************
; For demo purposes: create a companion TIME array use this to replace the 
; current time coordinate variable, then use this to access specific months
;***************************************  
  time  = f->t               ; read in current array 
  ntime = dimsizes(time)     ; number of months

  TIME  = cd_calendar(time, -1)
  TIME!0      ="TIME"
  TIME&TIME   = TIME         ; coordinate variable
  T_anom&t    = TIME         ; associate the new coordinate variable

;***************************************
; create plot
;***************************************  
  wks = gsn_open_wks("png","cru")            ; send graphics to PNG file

  plot= new (dimsizes(yyyymm), graphic)      ; create graphical array
  
  res                      = True            ; plot mods desired
  res@gsnDraw              = False           ; don't draw yet 
  res@gsnFrame             = False           ; don't advance frame yet 

  res@cnFillOn             = True            ; color contours
  res@cnFillPalette        = "gui_default"   ; set color map
  res@cnLinesOn            = False           ; turn off contour lines
  res@cnFillMode           = "RasterFill"    ; Raster Mode

  res@lbLabelBarOn         = False           ; turn off individual lb's

  do nt = 0,dimsizes(yyyymm)-1
     res@gsnLeftString   = "Temp Anomaly"                
     res@gsnCenterString = yyyymm(nt)
     plot(nt) = gsn_csm_contour_map(wks,T_anom({yyyymm(nt)},:,:),res)
  end do
;************************************************
; create panel plot
;************************************************

  resP                  = True                   ; modify the panel plot
;;resP@txString         = fili                   ; plot title
  resP@gsnMaximize      = True                   ; make ps, eps, pdf, ... large
  resP@gsnPanelLabelBar = True                   ; add common label bar
  gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot

end


