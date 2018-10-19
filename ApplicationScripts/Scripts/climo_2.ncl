;*****************************************************
; climo_2.ncl
;
; Concepts illustrated:
;   - Calculating monthly climatologies
;   - Calculating seasonal means
;   - Calculating an EOF analysis
;   - Turning off the bottom tickmark labels and tickmarks
;   - Paneling three plots vertically on a page
;   - Adding a common labelbar to paneled plots
;   - Drawing a time series plot
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;******************************************************
begin
;**************************
; open file and read in monthly data
;**************************
  f    = addfile ("xieArkin-T42.nc", "r")
  P    = f->prc
  ntim = dimsizes(P&time)             ; # time steps [months]
  nmos = 12
;**************************
; use functions in contributed.ncl
;**************************                               
  Pclm = clmMonTLL (P)       ; monthly climatology (12,nlat,mlon)
  Pstd = stdMonTLL (P)       ; stDev monthly means (12,nlat,mlon)
;**************************
; compute Seasonal means
;**************************    
  Psea = P(lat|:,lon|:,time|:)    ; reorder variable-to-variable transfer
  Psea = runave (Psea, 3, 1)      ; seasonal (3-month) averages
;**************************
; calculate eof's
;**************************        
  eofData = Psea(::4, ::4, 0:ntim-1:12) ; temporary
  eof   = eofcov_Wrap   (eofData,3) ; eof of seasonal means
  eofTs = eofcov_ts_Wrap(eofData,eof)  ; time series coef
;******************************************
; create plot
;******************************************
  wks   = gsn_open_wks("png","climo")        ; send graphics to PNG file
  plot  = new ( 3, "graphic")                ; create graphic array
  
  res                      = True            ; plot mods desired
  res@gsnDraw              = False           ; don't draw
  res@gsnFrame             = False           ; don't advance frame
  
  res@cnLevelSelectionMode = "ManualLevels"  ; manual contour levels
  res@cnMinLevelValF       = -0.40           ; min level
  res@cnMaxLevelValF       =  0.40           ; max level
  res@cnLevelSpacingF      =  0.04           ; interval
  
  res@cnFillOn             = True            ; turn on color
  res@cnFillPalette        = "gui_default"   ; set color map

  res@lbLabelBarOn         = False           ; turn off individual color bars
  
  res@tmXBOn               = False           ; eliminate bottom labels
  res@cnLinesOn            = False           ; no contour lines
  
  if (isatt(eof,"long_name")) then
    eof_LongName = eof@long_name ; save for later use as title
    delete (eof@long_name)
  end if
  
  do ne=0,2
    res@gsnLeftString    = "Covariance"
    res@gsnCenterString  = "EOF "+(ne+1)
    res@gsnRightString   = "%Var=" + sprintf("%4.1f", eof@pcvar(ne))
    plot(ne) = gsn_csm_contour_map_ce(wks,eof(ne,:,:), res)
  end do
  
  resP                      = True                    ; panel mods desired
  resP@gsnPanelLabelBar     = True                    ; common color bar
  resP@lbLabelStride        = 3                       ; every other label 
  gsn_panel(wks,plot,(/3,1/),resP)
;******************************************
; create plot of time series
;******************************************
  resxy          = True                              ; xy plot mods desired
  resxy@gsnDraw  = False                             ; don't draw yet
  resxy@gsnFrame = False                             ; don't advance frame yet
  resxy@vpWidthF = 0.80                              ; plot width
  resxy@vpHeightF= 0.50                              ; plot height
  
  time = eofTs&time
  
  do ne=0,2
    resxy@gsnLeftString    = "Covariance"           ; titles
    resxy@gsnCenterString  = "EOF "+(ne+1)
    resxy@gsnRightString   = "%Var=" + sprintf("%4.1f", eof@pcvar(ne))
    plot(ne) = gsn_csm_xy(wks,time,eofTs(ne,:), resxy)
  end do
  gsn_panel(wks,plot,(/3,1/),False)          ; draw: 1-across, 3-down
end

