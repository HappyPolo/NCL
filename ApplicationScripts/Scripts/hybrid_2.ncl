;-----------------------------------------------------
; hybrid_2.ncl
;-----------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   ; High Level
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    ; plot interfaces
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************************************** 
begin
;**************************
; open file and read in monthly data
;**************************
 f    = addfile ("XieArkin.nc", "r")
 P    = f->PRC
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
 wks   = gsn_open_wks("ncgm" ,"hybrid")
 gsn_define_colormap(wks,"gui_default")

 plot  = new ( 3, "graphic")     ; max 3 plots
 res                      = True            ; plot mods desired
 res@gsnDraw              = False           ; don't draw
 res@gsnFrame             = False           ; don't advance frame

 res@cnLevelSelectionMode = "ManualLevels"  ; manual contour levels
 res@cnMinLevelValF       = -0.40
 res@cnMaxLevelValF       =  0.40
 res@cnLevelSpacingF      =  0.04

 res@cnFillOn             = True            ; turn on color
 res@gsnSpreadColors      = True            ; use full color table
 res@gsnSpreadColorStart  = 2 
 res@gsnSpreadColorEnd    = -3 
 res@lbLabelBarOn         = False           ; turn off individual color bars

 res@tmXBOn               = False           ; eliminate bottom labels
 res@cnLinesOn            = False

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

  resP                      = True
  resP@gsnPanelLabelBar     = True                    ; common color bar
  resP@lbLabelStride        = 3                       ; every other label 
  gsn_panel(wks,plot,(/3,1/),resP)
  delete(resP)
;******************************************
; create plot of time series
;******************************************
  resxy          = True
  resxy@gsnDraw  = False
  resxy@gsnFrame = False
  resxy@vpWidthF = 0.80
  resxy@vpHeightF= 0.50

  time = eofTs&time
          
  do ne=0,2
     resxy@gsnLeftString    = "Covariance"
     resxy@gsnCenterString  = "EOF "+(ne+1)
     resxy@gsnRightString   = "%Var=" + sprintf("%4.1f", eof@pcvar(ne))
     plot(ne) = gsn_csm_xy(wks,time,eofTs(ne,:), resxy)
  end do
  gsn_panel(wks,plot,(/3,1/),resP)          ; draw: 1-across, 3-down
end

