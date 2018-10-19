;************************************************
; panel_9.ncl
;
; Concepts illustrated:
;   - Drawing an XY and polar/contour plot on the same page using viewport resources
;   - Using a blue-white-red color map
;   - Using indexed color to set contour fill colors
;   - Filling the areas of an XY curve above and below a reference line
;   - Drawing a Y reference line in an XY plot
;   - Turning off the map lat/lon grid lines
;   - Changing the size of a PNG image
;
;************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;********************
; get data
;********************
  dir = "./"
  fpath = dir+"nao.obs.nc"
  fo = addfile(fpath,"r")
  deppat = fo->nao_djf
  xyarr = fo->nao_pc_djf
;********************
; plot parameters
;********************
  wtype          = "png"
  wtype@wkWidth  = 1500    ; Increase size of PNG image.
  wtype@wkHeight = 1500
  wks = gsn_open_wks(wtype,"panel")
  gsn_define_colormap(wks,"BlWhRe")
;********************
; first plot
;********************
  res                      = True           ; plot mods desired
  res@gsnFrame             = False          ; don't advance frame
  res@gsnPolar             = "NH"           ; select northern hemisphere

  res@mpMinLatF            =  30            ; minimum latitude
  res@mpGridAndLimbOn      = False          ; turn off grid

  res@gsnTickMarksOn       = False          ; turn off tickmarks

  res@cnFillOn             = True               ; color fill
  res@cnLevelSelectionMode = "ManualLevels"  	; manually set the contour levels
  res@cnMinLevelValF       = -5.0
  res@cnMaxLevelValF       = 3.0
  res@cnLevelSpacingF      = .5
  res@cnFillColors         = (/100,90,75,71,68,65,62,60,57,55,52,52,49,47,44,42,39,36/)
  res@lbOrientation        = "Vertical"     ; vertical label bar

  res@tiMainString         = "North Atlantic Oscillation (DJF)" ; title
  res@gsnLeftString        = ""                             ; no left string
  res@gsnRightString       = ""                             ; no right string

; this controls the size and location of the first plot
  res@vpXF            = 0.2         
  res@vpWidthF        = 0.6	    
  res@vpYF            = 0.83
  res@vpHeightF       = 0.465   
 
  plot = gsn_csm_contour_map_polar(wks,deppat,res)

;*****************************************
; second plot
;*****************************************
  sres                      = True      ; plot mods desired
  sres@gsnFrame             = False     ; don't advance frame

  sres@trXMinF              = 1919      ; set X-axis max and mins
  sres@trXMaxF              = 2015
  sres@trYMinF              = -4.      ; set Y-axis max and mins
  sres@trYMaxF              =  3.      

  sres@xyLineThicknesses    = (/1./)      ; Define line thicknesses 
  sres@xyLineColors         = (/"black"/) ; Define line color
  sres@xyMonoDashPattern    = True

  sres@tmYLLabelFontHeightF = 0.015  ; font height
  sres@gsnTickMarksOn       = True        ; turn off tickmarks

  sres@gsnYRefLine          = 0.          ; Y-value for ref. line
  sres@gsnAboveYRefLineColor= "Red"   ; Color area above ref. line red
  sres@gsnBelowYRefLineColor= "Blue"  ; Color area below ref. line blue

  sres@gsnCenterString      = ""       ; no center string
  sres@tiXAxisOn            = False    ; turn off X-axis title 
 
; this controls the size and location of the second plot
  sres@vpXF                 = 0.15   
  sres@vpYF                 = 0.3     
  sres@vpWidthF             = 0.7
  sres@vpHeightF            = 0.18

  time = xyarr&time  ; time has units of YYYY
  tsmap2 = gsn_csm_xy(wks,time,xyarr,sres)
;*****************************************************
; create other thick line since we did not advance the frame,
; and did not panel this plot using gsn_panel(), we can do this.
;******************************************************
  delete([/sres@gsnYRefLine,sres@gsnAboveYRefLineColor,sres@gsnBelowYRefLineColor/])

  sres@xyLineThicknesses   = (/4./)     ; Define line thicknesses 
  sres@xyLineColors        = (/"black"/)

;*************************************************************
; use wgt_runave_Wrap to create a smoothed version of xyarr
;*************************************************************
  xyarr2 = wgt_runave_Wrap(xyarr,(/1.,3,5,6,5,3,1/), 0)   
  tsmap3=gsn_csm_xy(wks,time,xyarr2,sres) 
  frame(wks)             ; advance frame after extra line drawn       
end
