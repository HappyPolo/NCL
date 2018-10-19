;======================================================================
; animate_3_3.ncl
;
; Concepts illustrated:
;   - Creating animations
;   - Animating WRF reflectivity data over a terrain map across time
;   - Removing a plot that has been overlaid on another plot so it can be reused
;   - Using get_cpu_time to calculate the CPU time for a script to execute
;   - Drawing partially transparent filled contours
;   - Using "setvalues" to change the data and titles in existing plots
;   - Drawing raster and smooth contours
;   - Using two different colormaps on one frame
;======================================================================
; This example generates an animation aross time of filled contours of
; reflectivity overlaid on a terrain map. The reflectivity field changes
; with each time step, while the terrain map is static.
;
; This example uses "setvalues" to speed up the creation of the 
; reflectivity contours.
; 
; "setvalues" allows you to change attributes of an existing plot to 
; create a new plot, without having to regenerate the plot from scratch.
;======================================================================
; See animate_3_1.ncl for the more traditional method of generating the
; same set of plots, and animate_3_2.ncl for another faster method.
;======================================================================

begin
  start_cpu_time = get_cpu_time()     ; We will time this example

;---Open files
  dir   = "~/ncargtest/nclscripts/wrf_files/"
  files = systemfunc("ls " + dir + "wrfout_d01_2008-09*")
  a     = addfiles(files,"r")

;---Read variables
  hgt   = a[:]->HGT(0,:,:)                 ; terrain, 0 is the first time step
  dbz   = wrf_user_getvar(a,"dbz",-1)      ; reflectivity
  times = wrf_user_list_times(a)           ; time as character strings

  printMinMax(dbz,0)
  printVarSummary(dbz)

;---Set all values < -28 to missing, so they don't get contoured.
  dbz@_FillValue = -999.
  dbz            = where(dbz.lt.-28,dbz@_FillValue,dbz)
  ntim           = dimsizes(dbz(:,0,0,0))
  ilev           = 0                        ; which level to plot

;---Open workstation
  wtype = "png"
  wtype@wkWidth = 2500
  wtype@wkHeight = 2500
  wks = gsn_open_wks(wtype,"animate")

;---Set some common resources
  res                       = True
  res@gsnDraw               = False    ; turn off draw
  res@gsnFrame              = False    ; turn off frame
  res@cnFillOn              = True     ; turn on contour fill
  res@cnLinesOn             = False    ; turn off contour lines
  res@cnLineLabelsOn        = False    ; turn off contour line labels

  res@gsnLeftString         = ""       ; turn off subtitles
  res@gsnRightString        = ""
  res@gsnCenterString       = ""

  res@lbLabelFontHeightF       = 0.015    ; size of labelbar labels
  res@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot
;
; Setting these four resources is necessary to keep
; the plot from running off the frame.
;
; The plot size will be slightly adjusted internally
; by NCL to preserve the aspect ratio of the map.
;
  res@vpXF                  = 0.08
  res@vpYF                  = 0.88
  res@vpWidthF              = 0.80
  res@vpHeightF             = 0.60
  res@tfDoNDCOverlay        = True      ; faster plotting if we use native WRF map projection

;---Copy common resources for terrain plot
  tres = res 
  tres = wrf_map_resources(a[0],tres)    ; Use first file in list for map proj info

  tres@cnLevelSelectionMode  = "ExplicitLevels"
  tres@cnLevels              = ispan(1,2200,200)
  tres@cnFillPalette         = "OceanLakeLandSnow"
  tres@cnFillOpacityF        = 0.5                 ; make contours partially transparent
  tres@lbLabelBarOn          = False               ; we don't need this

;---Copy common resources for dbz plot
  dres                       = res      

  dres@cnFillMode            = "RasterFill"
  dres@cnLevelSelectionMode  = "ExplicitLevels"
  dres@cnLevels              = ispan(-28,50,8)
  dres@lbOrientation         = "Vertical"

;---Read in colormap so we can subset it.
  cmap_r                     = read_colormap_file("WhViBlGrYeOrRe")
  dres@cnFillPalette         = cmap_r(6:,:)  ; skip the first few colors

;---Create the terrain map with initial title, first dbz plot, and overlay
  tres@tiMainString = times(0)
  ter_plot = gsn_csm_contour_map(wks,hgt,tres)
  dbz_plot = gsn_csm_contour(wks,dbz(0,ilev,:,:),dres)
  overlay(ter_plot,dbz_plot)

;---Loop through each time step and draw a new plot
  do nt=0,ntim-1
;---Don't plot missing or constant fields
    if(all(ismissing(dbz(nt,ilev,:,:))).or.(min(dbz(nt,ilev,:,:)).eq.max(dbz(nt,ilev,:,:)))) then
      print("Field is constant at time='" + times(nt) + "'.  Skipping...")
      continue
    else
      print("time='" + times(nt) + "'")
    end if

;---Use "setvalues" to update the two plots
    if(nt.gt.0) then
      setvalues ter_plot                                         ; Change the title
        "tiMainString" : times(nt)
      end setvalues
      setvalues dbz_plot@data                                    ; Change the data
        "sfDataArray" : dbz(nt,ilev,:,:)
      end setvalues
    end if

;---Drawing the terrain plot will also draw dbz plot
    draw(ter_plot)                                              ; Drawing the terrain plot will 
    frame(wks)
  end do

;---Calculate total time for this example.
  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")
end
