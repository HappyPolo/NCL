;*************************************************
; bfband_3.ncl
;
; Concepts illustrated:
;   - Specifying region and bandwidth  
;   - Applying 'bw_bandpass_filter' to time series at each grid point
;   - Plotting the band passed data every 5 days
;************************************************
; # These libraries are automatically loaded from 6.2.0 onward #
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    


; ***********************************************
; Specify assorted constants
; ***********************************************
  latS    = -25.0         ; lat band to read
  latN    =  25.0
  lonL    = 100.0
  lonR    = 270.0

  ca      = 60            ; band width in days
  cb      = 40     

  pStrt   = 19970115      ; specify a start date 
                          ; NOTE: 96-97 MJO gold standard
  daySkip = 5             ; frequency of plotting

  pltType = "png"         ; send graphics to PNG file
  pltName = "bfband"

; ***********************************************
; Read the full time series for specified region
; This could easily be changed to just a temporal subset
; ***********************************************
  diri    = "./"
  fili    = "uwnd.day.850.anomalies.1980-2005.nc"
  f       = addfile(diri+fili, "r")   
  u       = f->U_anom(:,{latS:latN},{lonL:lonR})

  dimu    = dimsizes(u)
  ntim    = dimu(0)
  nlat    = dimu(1)
  mlon    = dimu(2)

; ***********************************************
; Butterworth filter; use defaults
; ***********************************************

  fca     = 1.0/ca
  fcb     = 1.0/cb
  opt     = False                              ; use defaults

  u_bf    = bw_bandpass_filter(u,fca,fcb,opt, 0)     ; dims=0

  printVarSummary(u_bf)                        
  copy_VarMeta(u,u_bf)

  u_bf@long_name = "BW Bandpass: "+cb+"-"+ca+" day"
  printVarSummary(u_bf)

; ***********************************************
; Create new date array for use on the plot
; Spwcify a start day
; ***********************************************

  date    = cd_calendar(u&time,-2)        ; yyyymmdd
  yrfrac  = yyyymmdd_to_yyyyfrac (date, 0)
  delete( [/yrfrac@long_name, u_bf@long_name/] )

  iStrt = ind(date.eq.pStrt)              ; user specified dates

; ***********************************************
; create new date array for use on the plot
; ***********************************************

  plot    = new ( 8, "graphic") 
  wks     = gsn_open_wks (pltType,pltName)

  cmap = read_colormap_file("precip4_diff_19lev") ; read color data
  cmap = cmap(::-1,:)                             ; reverse colormap

  res                      = True              ; plot mods desired
  res@gsnMaximize          = True
  res@gsnAddCyclic         = False             ; regional grid
  res@gsnDraw              = False             ; don't draw
  res@gsnFrame             = False             ; don't advance frame
  res@gsnStringFontHeightF = 0.015             ; set the center string font height

  res@cnFillOn             = True
  res@cnFillPalette        = cmap              ; set color map
  res@cnLinesOn            = False             ; turn of contour lines
  res@cnLineLabelsOn       = False    
  res@cnLevelSelectionMode = "ManualLevels"    ; set manual contour levels
  res@cnMinLevelValF       =   -4.             ; set min contour level
  res@cnMaxLevelValF       =    4.             ; set max contour level
  res@cnLevelSpacingF      =   0.5             ; set contour spacing

  res@lbLabelBarOn         = False             ; turn off individual cb's

  res@mpMinLatF            = latS              ; range to zoom in on
  res@mpMaxLatF            = latN  
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR
  res@mpCenterLonF         = 0.5*(res@mpMinLonF+res@mpMaxLonF)

  do nt=0,7                
     res@gsnCenterString = date(iStrt+daySkip*nt)
     plot(nt) = gsn_csm_contour_map(wks,u_bf(iStrt+daySkip*nt,:,:), res)
  end do

;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
  resP@txString            = "Butterworth Filtered: "+cb+"-"+ca+" day: "+u@long_name
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  gsn_panel(wks,plot,(/4,2/),resP)               ; now draw as one plot
