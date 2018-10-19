;**********************************************************
; coneff_6.ncl
;
; Concepts illustrated:
;   - Drawing contours over a polar stereographic map
;   - Drawing positive, negative, and zero contour lines in different colors
;   - Drawing negative contour lines as dashed lines
;   - Calculating a running average
;   - Calculating long term monthly means from monthly data
;
;**********************************************************
; Adam Phillips
;
; will compute the climatology of 300mb ZZP for JFM. 
; The climatology will be plotted above the regression plot that was 
; computed by regressing JFm 300mb ZZP onto the JFM PC1 Ts.  
;***********************************************************
;
; These files are loaded by default in NCL V6.2.0 or newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*****************************************************
begin

;======================
; access data
;======================
  in = addfile("zzp300.monthly.1948_1998.nc","r")
  tser = in->ZZP({25:},:,:)
  tser&lat@units = "degrees_north"  ; Fix the units attributes.
  tser&lon@units = "degrees_east"

  dimice=dimsizes(tser)
  nlat2=dimice(0)
  mlon2=dimice(1)
  ntim2=dimice(2)
;==================================
; Calculate the JFM Clim.
;==================================
  soi1     = runave(tser,3,0)
  jfmclim  = dim_avg(soi1(:,:,1:ntim2-1:12))
;====================================
; Calculate and Remove the Long-Term 
; Monthly Means, + compute JFM Avg.
;====================================
  slp_clm = clmMonLLT (tser)
  newslp  = calcMonAnomLLT(tser,slp_clm) ;Calculate Anomalies from Means

  temptemp = newslp(:,:,:50)
  temp     = runave(newslp,3,0)
  temptemp = (/ temp(:,:,1:ntim2-1:12) /)    ;Grab JFM average

;==========================
; Read in the pc Ts
;==========================
  cdf = addfile("slp.pc1ts.nc","r")
  pcts = cdf->JFMAVG(49:99)
  pcts@_FillValue = 1.e+36
;========================
; Begin regression calcs 
;========================
  regres_t = regCoef(pcts,temptemp)
  copy_VarMeta(temptemp(:,:,0),regres_t)

;==========================
; Remove unneeded variables
;==========================
  delete([/temp,temptemp,slp_clm,newslp,soi1,jfmclim,pcts/])

;========================
; plot parameters
;========================
  wks = gsn_open_wks ("png", "coneff" ) ; send graphics to PNG file

  res = True

  res@gsnPolar         = "NH"           ; choose hemisphere 
  res@mpMinLatF        = 30             ; minimum lat
  res@mpOutlineOn      = True           ; turn on map outline
  res@mpGridAndLimbOn  = "False"        ; turn off lat/lon lines

  res@tmXBLabelsOn   = False            ; no labels or tick marks
  res@tmYLLabelsOn   = False
  res@gsnTickMarksOn = False
  res@tmXBOn         = False
  res@tmXTOn         = False 
  res@tmYLOn         = False 
  res@tmYROn         = False 

  res@tiMainString     = "More contour effects"   ; title
  res@cnLineThicknessF = 1.5                      ; thicker lines
  res@cnLineLabelsOn   = False                    ; no line labels

  res@gsnDraw          = False   ; don't draw yet
  res@gsnFrame         = False   ; don't advance frame yet

  plot = gsn_csm_contour_map_polar(wks,regres_t,res)
  plot = ColorNegDashZeroPosContour(plot,"red","magenta","blue")
  draw(plot)
  frame(wks)
end
