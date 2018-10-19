;*************************************************
; ESMF_regrid_21.ncl
;*************************************************
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating unstructured data to a 0.1 degree grid.
;   - Paneling three plots on a page
;   - Turning off the top and right tickmarks
;   - Contouring one-dimensional X, Y, Z data
;   - Reading an ASCII file with several columns of data
;   - Adding filled dots to a map
;   - Using a blank plot to add text to the frame
; ----------------------------------------------------------------------
; This example reads in station data represented by 1D arrays.
; ----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;
; Data is stored in four columns:
;
;     station_name  lat  lon  pwv
;
; Read in each line as a string, and use "str_get_field" to 
; read in the fields of interest.
;
  fname = "pw.dat"
  lines = asciiread(fname,-1,"string")

;
; Use "str_get_field" to indicate which fields to read in. Each field
; is separated by spaces.
;
  lat    = tofloat(str_get_field(lines(1:),2," "))
  lon    = tofloat(str_get_field(lines(1:),3," "))
  pwv    = tofloat(str_get_field(lines(1:),4," "))
  minlat = min(lat)
  maxlat = max(lat)
  minlon = min(lon)
  maxlon = max(lon)

;---Set up options for regridding to 0.1 degree grid
  Opt                 = True

  Opt@SrcGridLat      = lat
  Opt@SrcGridLon      = lon

;---If you don't set these two, the regridding will be VERY slow
  Opt@DstLLCorner     = (/floor(minlat)-0.1,floor(minlon)+0.1/)
  Opt@DstURCorner     = (/ ceil(maxlat)-0.1, ceil(maxlon)+0.1/)
  Opt@DstGridType     = "0.1deg"                ; destination grid

  Opt@ForceOverwrite  = True
  Opt@Debug           = True

;---Do two types of regridding: bilinear and patch
  Opt@InterpMethod    = "bilinear"
  pwv_regrid_b = ESMF_regrid(pwv,Opt)

  Opt@InterpMethod    = "patch"
  pwv_regrid_p = ESMF_regrid(pwv,Opt)

  printVarSummary(pwv_regrid_b)
  printVarSummary(pwv_regrid_p)

;---Plotting section
  wks = gsn_open_wks("png","ESMF_regrid")   ; send graphics to PNG file

  res                             = True
  res@gsnDraw                     = False   ; will panel later
  res@gsnFrame                    = False

  mnmxint = nice_mnmxintvl( min(pwv), max(pwv), 25, False)

;---Be sure to use same levels for both plots
  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = mnmxint(0)
  res@cnMaxLevelValF              = mnmxint(1)
  res@cnLevelSpacingF             = mnmxint(2)

  res@cnFillOn                    = True
  res@cnLinesOn                   = False
  res@cnLineLabelsOn              = False
  res@lbLabelBarOn                = False

  res@mpFillOn                    = False
  res@mpMinLatF                   = floor(minlat)-0.5
  res@mpMaxLatF                   =  ceil(maxlat)+0.5
  res@mpMinLonF                   = floor(minlon)-0.5
  res@mpMaxLonF                   =  ceil(maxlon)+0.5

;---Draw US states in a light gray
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpUSStateLineColor          = "Gray10"

;---Turn off top and right tickmarks and their labels
  res@tmXTOn                      = False
  res@tmYROn                      = False

  res@gsnAddCyclic                = False

  res@tiMainFontHeightF           = 0.02

;---Resource for plotting original data
  ores = res

  ores@sfXArray                    = lon
  ores@sfYArray                    = lat
  ores@tiMainString                = "GPS PWV (18Z) (original)"

;---Create plot of original data
  map_orig   = gsn_csm_contour_map(wks,pwv,ores)

  res@tiMainString  = "Regridded to 0.1 deg using 'bilinear'"
  map_regrid_b = gsn_csm_contour_map(wks,pwv_regrid_b,res)

  res@tiMainString  = "Regridded to 0.1 deg using 'patch'"
  map_regrid_p = gsn_csm_contour_map(wks,pwv_regrid_p,res)

  getvalues map_orig
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

;
; Create a blank plot that is the same size as the other three plots.
; We will use this blank plot as a canvas for adding some text strings.
; This plot will be part of the panelled set of plots.
;
  bres           = True
  bres@vpWidthF  = vpw     ; Set to same width/height
  bres@vpHeightF = vph     ; as previous plots.
  bres@gsnDraw   = False   ; Will panel later.
  bres@gsnFrame  = False

;---Turn off all tickmarks, labels, and borders
  bres@tmXBOn       = False
  bres@tmYLOn       = False
  bres@tmXTOn       = False
  bres@tmYROn       = False
  bres@tmXBBorderOn = False
  bres@tmXTBorderOn = False
  bres@tmYLBorderOn = False
  bres@tmYRBorderOn = False

  blank_plot = gsn_blank_plot(wks,bres)

;---Resources for adding text
  txres               = True
  txres@txFontHeightF = 0.02
  txres@txJust        = "CenterLeft" 
  txres@txFontColor   = "NavyBlue"

  strs = (/"This example shows how to regrid", \
           "unstructured data to a 0.1 degree", \
           "grid using ESMF_regrid. Only the", \
           "'bilinear' and 'patch' methods are", \
           "used here. The filled dots show the", \
           "locations of the original lat/lon data."/)

  nstr = dimsizes(strs)
  text = new(nstr,graphic)

  ypos = 0.9
  do i=0,nstr-1
    ypos = ypos - 0.10
    text(i) = gsn_add_text(wks,blank_plot,strs(i),0.01,ypos,txres)
  end do

;---Add markers to all three plots showiing original lat/lon locations
  mkres               = True
  mkres@gsMarkerIndex = 16     ; Filled circle
  mkres@gsMarkerSizeF = 0.008

  dum1 = gsn_add_polymarker(wks,map_orig,lon,lat,mkres)
  dum2 = gsn_add_polymarker(wks,map_regrid_b,lon,lat,mkres)
  dum3 = gsn_add_polymarker(wks,map_regrid_p,lon,lat,mkres)

  pres                    = True
  pres@gsnPanelLabelBar   = True
  pres@pmLabelBarWidthF   = 0.7
  pres@gsnMaximize        = True
  pres@lbBoxLinesOn       = False
  pres@lbLabelFontHeightF = 0.01

  gsn_panel(wks,(/map_orig,blank_plot,map_regrid_b,map_regrid_p/),(/2,2/),pres)

end 
