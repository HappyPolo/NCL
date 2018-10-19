;----------------------------------------------------------------------
; wrf_title_5.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Customizing titles in plots created by wrf_xxxx functions
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.4.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open WRF output file and read variables
  a = addfile("wrfout_d01_2008-09-30_00:00:00.nc","r")

  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  nt    = 0                              ; time step to plot

  slp = wrf_user_getvar(a,"slp",nt)    ; slp
  wrf_smooth_2d( slp, 3 )              ; smooth slp
  tc  = wrf_user_getvar(a,"tc",nt)      ; 3D tc 
  td  = wrf_user_getvar(a,"td",nt)      ; 3D td 
  u   = wrf_user_getvar(a,"ua",nt)      ; 3D U at mass points
  v   = wrf_user_getvar(a,"va",nt)      ; 3D V at mass points
  td2 =  wrf_user_getvar(a,"td2",nt)   ; Td2 in C
  tc2 = wrf_user_getvar(a,"T2",nt)     ; T2 in Kelvin
  u10 = wrf_user_getvar(a,"U10",nt)    ; u at 10 m, mass point
  v10 = wrf_user_getvar(a,"V10",nt)    ; v at 10 m, mass point

;---Convert variables to other units
  tc2  = tc2-273.16                    ; T2 in C
  tf2  = 1.8*tc2+32.                   ; Turn temperature into Fahrenheit
  td_f = 1.8*td2+32.                   ; Turn temperature into Fahrenheit
  u10  = u10*1.94386                   ; Turn wind into knots
  v10  = v10*1.94386

;---Update metadata
  tf2@description  = "Surface Temperature"
  td_f@description = "Surface Dew Point Temp" 
  tf2@units        = "degF"
  td_f@units       = "degF"
  u10@units        = "kts"
  v10@units        = "kts"

;---Start the graphics
  wks = gsn_open_wks("png","wrf_title")

  res            = True
  res@MainTitle  = "REAL-TIME WRF"     ; Set main title at top left of page
  res@TimeLabel  = times(nt)           ; Set valid time to use below init time

;---Plotting options for T (filled contours)
  opts                   = res                         
  opts@cnFillOn          = True  
  opts@cnFillPalette     = "BlAqGrYeOrReVi200"
  opts@ContourParameters = (/ -20., 90., 5./)
  contour_tc = wrf_contour(a,wks,tf2,opts)
  delete(opts)

;---Plotting options for Td (filled contours)
  opts                            = res                         
  opts@cnFillOn                   = True
  opts@cnFillPalette              = "BlAqGrYeOrReVi200"
  opts@cnLineLabelsOn             = True
  opts@ContourParameters          = (/ -20., 90., 5./) 
  opts@cnLineLabelBackgroundColor = "transparent"
  contour_td = wrf_contour(a,wks,td_f,opts)
  delete(opts)

;---Plotting options for SLP (line contours)
  opts                            = res                         
  opts@cnLineColor                = "Blue"
  opts@cnHighLabelsOn             = True
  opts@cnLowLabelsOn              = True
  opts@ContourParameters          = (/ 900., 1100., 4. /)
  opts@cnLineLabelBackgroundColor = "transparent"
  opts@cnLineThicknessF           = 2.0
  contour_slp = wrf_contour(a,wks,slp,opts)
  delete(opts)

;---Plotting options for wind vectors
  opts            = res         
  opts@FieldTitle = "Wind"       ; overwrite Field Title
  opts@NumVectors = 47           ; density of wind barbs
  vector = wrf_vector(a,wks,u10,v10,opts)
  delete(opts)
  
;---Create two different sets of plots; note the various titles
  pltres = True
  mpres  = True
  plot = wrf_map_overlays(a,wks,(/contour_tc,contour_slp,vector/),pltres,mpres)
  plot = wrf_map_overlays(a,wks,(/contour_td,vector/),pltres,mpres)
end
