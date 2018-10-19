;--------------------------------------------------------------------
; wavelet_3.ncl
;
; Concepts illustrated:
;   - Computing wavelets
;   - Overlaying a stippling pattern to show area of interest
;   - Changing the size of the dot fill pattern in gsn_contour_shade
;   - Increasing the density of fill patterns
;--------------------------------------------------------------------
;
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;--------------------------------------------------------------------
; CREATE SAME WAVELET FIGURE AS TORRENCE & COMPO using seasonal Nino3
; from 1871-1997
;--------------------------------------------------------------------

begin
  ninoseas = asciiread("sst_nino3.dat",-1,"float")
  ninoseas!0 = "time"
  ntime = dimsizes(ninoseas)
  timeo = fspan(1871.25,1996.,ntime)
  ninoseas&time = timeo

  ninomam = dim_avg_Wrap(ninoseas(0::4))
  ninojja = dim_avg_Wrap(ninoseas(1::4))
  ninoson = dim_avg_Wrap(ninoseas(2::4))
  ninodjf = dim_avg_Wrap(ninoseas(3::4))

  ninoseas(0::4) = ninoseas(0::4) - ninomam
  ninoseas(1::4) = ninoseas(1::4) - ninojja
  ninoseas(2::4) = ninoseas(2::4) - ninoson
  ninoseas(3::4) = ninoseas(3::4) - ninodjf

  time  = timeo
  N     = dimsizes(time)
;************************************
; compute wavelet
;************************************
  mother  = 0
  param   = 6.0
  dt      = 0.25    ;timesteps in units of years
  s0      = dt
  dj      = 0.25
  jtot    = 1+floattointeger(((log10(N*dt/s0))/dj)/log10(2.))
  npad    = N
  nadof   = 0
  noise   = 1
  siglvl  = .05
  isigtest= 0

  w = wavelet(ninoseas,mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)
;************************************
; create coodinate arrays for plot
;************************************
  power            = onedtond(w@power,(/jtot,N/))
  power!0          = "period"                        ; Y axis
  power&period     = w@period                      ; convert period to units of years

  power!1          = "time"                          ; X axis
  power&time       = time

  power@long_name  = "Power Spectrum"
  power@units      = "1/unit-freq"

; compute significance ( >= 1 is significant)
  SIG              = power                            ; transfer meta data
  SIG              = power/conform (power,w@signif,0)
  SIG@long_name    = "Significance"
  SIG@units        = " "
;********************************************************************************
; initial resource settings
;********************************************************************************
  wks = gsn_open_wks("png","wavelet")             ; send graphics to PNG file

  res                     = True                  ; plot mods desired
  res@gsnMaximize         = True
  res@gsnDraw             = False                 ; Do not draw plot
  res@gsnFrame            = False                 ; Do not advance frome

  res@vpHeightF           = .4                    ;
  res@vpWidthF            = .7

  res@cnFillOn            = True                  ; turn on color
  res@cnFillPalette       = "StepSeq25"           ; set color map
  res@cnFillMode          = "RasterFill"          ; turn on raster mode
  res@cnFillOpacityF      = 0.50                  ; make partially transparent
  res@cnRasterSmoothingOn = True                  ; turn on raster smoothing
  res@cnLinesOn           = False                 ; turn off contour lines
  res@cnLineLabelsOn      = False

  res@cnInfoLabelOn       = False
  res@trYReverse          = True                  ; reverse y-axis

  res@cnLevelSelectionMode = "ExplicitLevels"       ; set manual contour levels
  res@cnLevels             = (/0.5,1.,2.,4./)

  res@gsnRightString       = "Wavelet Power"
  res@gsnLeftString        = "NINO3: GISST"
  res@tiYAxisString        = "Period"

  res@tmYLMode            = "Explicit"
  res@tmYLValues          = (/1,2,4,8,16,32,64,128/)
  res@tmYLLabels          = "" + res@tmYLValues
  res@tmLabelAutoStride   = True

  res@tiMainFontHeightF    = 0.018
  res@tiMainFont           = "helvetica-bold"
  res@gsnStringFontHeightF = 0.015
  res@tiXAxisFontHeightF   = 0.014
  res@tiYAxisFontHeightF   = 0.014
  res@tmXBLabelFontHeightF = 0.013
  res@pmLabelBarHeightF    = 0.08

  res2 = True                            ; res2 probability plots
  res2@gsnDraw             = False       ; Do not draw plot
  res2@gsnFrame            = False       ; Do not advance frome

  res2@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res2@cnMinLevelValF      = 0.00        ; set min contour level
  res2@cnMaxLevelValF      = 2.00        ; set max contour level
  res2@cnLevelSpacingF     = 1.00        ; set contour spacing
  res2@cnInfoLabelOn       = False
  res2@cnLinesOn           = False       ; do not draw contour lines
  res2@cnLineLabelsOn      = False       ; do not draw contour labels

  res2@trYReverse          = True

  res2@tmYLMode            = "Explicit"
  res2@tmYLValues          = (/1,2,4,8,16,32,64,128/)
  res2@tmYLLabels          = "" + res2@tmYLValues

  res2@gsnLeftString       = ""
  res2@gsnRightString      = ""

;---Create the same plot three times so we can compare different fill scales and dot densities.

  res@tiMainString = "Default fill scale for hatch pattern"
  plot_hatch_def = gsn_csm_contour(wks,power,res)

  res@tiMainString = "Increased fill scale for hatch pattern"
  plot_hatch_scl = gsn_csm_contour(wks,power,res)

  res@tiMainString = "Increased fill scale and size for stippling"
  plot_stipple   = gsn_csm_contour(wks,power,res)

  iplot_hatch_def = gsn_csm_contour(wks,SIG,res2)
  iplot_hatch_scl = gsn_csm_contour(wks,SIG,res2)
  iplot_stipple   = gsn_csm_contour(wks,SIG,res2)

;
; Apply three different types of stippling to the three plots:
;   - Shading with hatch pattern
;   - Shading with increased density of hatch pattern
;   - Shading with increased density of stipple and dot size.
;
  opt                      = True
  opt@gsnShadeHigh         = 6           ; cross hatch pattern
  opt@gsnShadeFillType     = "pattern"
  iplot_hatch_def = gsn_contour_shade(iplot_hatch_def,0, 0.8, opt)

  opt@gsnShadeFillScaleF   = 0.3         ; add extra density
  iplot_hatch_scl = gsn_contour_shade(iplot_hatch_scl,0, 0.8, opt)

  opt@gsnShadeHigh         = 17          ; stipple
  opt@gsnShadeFillScaleF   = 0.5         ; add extra density
  opt@gsnShadeFillDotSizeF = 0.002      ; make dots larger
  iplot_stipple = gsn_contour_shade(iplot_stipple,0, 0.8, opt)

  overlay(plot_hatch_def,iplot_hatch_def)
  draw(plot_hatch_def)
  frame(wks)

  overlay(plot_hatch_scl,iplot_hatch_scl)
  draw(plot_hatch_scl)
  frame(wks)

  overlay(plot_stipple,iplot_stipple)
  draw(plot_stipple)
  frame(wks)

end
