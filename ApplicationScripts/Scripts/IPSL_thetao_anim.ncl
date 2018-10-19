;----------------------------------------------------------------------
; This script creates an animation across "time" of the 
; "thetao" variable.
;
; This script creates an IPSL_thetao_5.ps file, and then
; converts this to an animation using the "convert" tool
; from ImageMagick. See the "system" call at the end of
; this script.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  filename = "FRCCORE2_e_1m_19980101_20071231_thetao.nc"
  f        = addfile (filename, "r")
  thetao   = f->thetao              ; (time_counter, deptht, y, x) 
  lat2d    = f->nav_lat             ; (y,x)
  lon2d    = f->nav_lon             ; (y,x)
  nt       = 0                      ; time index to plot
  nd       = 0                      ; depth index to plot

;---Convert 'time' coordinate array to better units
  date     = cd_string(t&time, "%D-%c%y" )  ; 03-Oct 2000

;---Start the graphics
  ps_filename_prefix = get_script_prefix_name()
  ps_filename        = ps_filename_prefix + ".ps"
  wks = gsn_open_wks("ps", ps_filename_prefix)
  gsn_define_colormap(wks,"rainbow")             ; Change color map

;---Set some resources
  res              = True

  res@gsnMaximize  = True               ; Maximize size of plot
  res@tiMainString = filename           ; Use filename as main title

;---This will position data correctly on map.
  res@sfXArray     = lon2d
  res@sfYArray     = lat2d

  res@gsnAddCyclic = False      ; Cyclic point already added

  res@cnFillOn        = True          ; Turn on contour fill
  res@cnLinesOn       = False         ; Turn off contour lines
  res@cnLevelSpacingF = 1.25          ; NCL was using 2.5

  res@cnFillMode = "RasterFill"

;
; Select nice contour levels to use across whole dataset.
; This is important if you are going to create an animation.
;
  mnmxint = nice_mnmxintvl( min(thetao), max(thetao), 20, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = mnmxint(0)
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)
 
;---Loop across each timestep and create a plot.
  do nt=0,dimsizes(date)-1
    res@gsnCenterString = date(nt) + ", z=" + thetao&deptht(nd)
    print("Plotting time = " + date(nt) + "...")
    plot = gsn_csm_contour_map(wks,thetao(nt,nd,:,:),res)
  end do

;---Create an animated GIF using "convert"
  delete(wks)    ; Make sure PS file is closed
  print("Creating an animated GIF...")
  system("psplit " + ps_filename)
  system("convert -rotate -90 -delay 25 pict0*.ps " + \
          ps_filename_prefix + ".gif")
  system("/bin/rm pict0*.ps")
end
