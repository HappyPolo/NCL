;**************************************************
; This will plot CALIPSO depolarization.
; Author:  Cory Wolff from UCAR, depolarization edits by Mike Madden
; Contact information: cwolff@ucar.edu; jmmadden@alaska.edu
;**************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
;load "color_map.ncl"
;**************************************************
begin

;----------------------------------------------
;  OPEN CALIPSO FILE AND WORKSTATION
;----------------------------------------------
 diri = "./"
 fili = systemfunc("cd "+diri+" ; ls CAL_LID_L2_05kmAPro-Prov*hdf_Subset.hdf")
 nfil = dimsizes(fili)  ; nfil = number of CALIPSO files, use for loop.

 f = addfiles(diri+fili + ".hdf","r")
 wks = gsn_open_wks("ps","calipso")

;----------------------------------------------
;  CREATE A LOOP TO READ EACH FILE SEQUENTIALLY
;----------------------------------------------

do ifile = 0, nfil-1

;----------------------------------------------
;  TO GET CALIPSO DEPOLARIZATION, TAKE THE RATIO OF PERPENDICULAR ATTENUATED BACKSCATTER OVER TOTAL ATTENUATED BACKSCATTER, BOTH AT 532 NM
;----------------------------------------------
  
;----------------------------------------------
;  READ CALIPSO DATA
;----------------------------------------------
  tot      = f[ifile]->Total_Attenuated_Backscatter_532
  perp     = f[ifile]->Perpendicular_Attenuated_Backscatter_532
  depol1   = perp/tot 
  depol1!0 = "first"
  depol1!1 = "second"

;----------------------------------------------
;  REVERSE VERTICAL ARRAY AND REORDER USING STRING DIMENSION NAMES
;----------------------------------------------
   depol1 = depol1(:,::-1)
   depol  = depol1(second|:,first|:)
   depol@_FillValue = -9999
   depol@units      = "km~S~-1~NN~ sr~S~-1~NN~"

;----------------------------------------------
;  GET LATITUDE AND LONGITUDE FOR THE X-AXIS AND FORMAT THE LABELING
;----------------------------------------------
   lat = (/f[ifile]->Latitude/)
   lon = (/f[ifile]->Longitude/)
   xlabel = sprintf("%.2f",lat)+"~C~"+sprintf("%.2f",lon)

;----------------------------------------------
;  GET TIME FIELDS TO GET A TIME STRING, WHICH WILL BE USED TO STRIDE X-AXIS LATITUDE AND LONGITUDE
;----------------------------------------------
   time    = (/f[ifile]->Profile_Time/)
   time@units = "seconds since 1993-01-01 00:00"
   tstring = ut_string(time(:,0), "%Y-%N-%D %H:%M:%S")
   stride  = dimsizes(tstring)/15

;----------------------------------------------
;  GET ALTITUDE VALUES; ALTITUDE VALUES ARE BASED ON CALIPSO RANGE GATE SPECIFICATIONS --- PAPER IS REFERENCED HERE: http://www-calipso.larc.nasa.gov/products/
;----------------------------------------------
   hgt    = asciiread("lidar_altitudes.txt", -1, "float")
   hgt    = hgt(::-1) ; Reverse this array too
   hgt!0  = "hgt"
   hgt@long_name = "Altitude, km"
   hgt@units     = "km"

;----------------------------------------------
;  ASSIGN NEW DIMENSIONS AND ATTRIBUTES TO COORDINATE CALIPSO DATA WITH ALTITUDE
;----------------------------------------------
   depol!0   = "hgt"
   depol&hgt =  hgt
   xcoord    = ispan(0,dimsizes(lat(:,0)) - 1,1)
   depol!1   = "xcoord"
   depol&xcoord = xcoord 

;---------------------------------------------
;  PLOTTING RESOURCES
;---------------------------------------------
   setvalues NhlGetWorkspaceObjectId()
        "wsMaximumSize": 300000000
   end setvalues

   colorMap = read_colormap_file("BlAqGrYeOrRe")
   colorMap(0,:) = (/ 0., 0., 0., 1./)   
   res = True
   res@cnFillOn            = True            ; color plot desired
   res@cnLinesOn           = False
   res@cnFillPalette 	   = colorMap
   res@cnSpanFillPalette   = True
   res@cnRasterModeOn      = True
   res@gsnAddCyclic        = False
   res@gsnMaximize         = True
   res@gsnLeftString       = "UTC: "+tstring(0)+" to "+tstring(dimsizes(tstring)-1)
   res@tiMainString        = "Attenuated Depolarization Ratio"
   res@tiMainFontHeightF   = 0.025
   res@tiYAxisFontHeightF  = 0.02

;---------------------------------------------
;  SET SPECIAL LEVELS
;---------------------------------------------
   res@cnLevelSelectionMode = "ExplicitLevels"
   res@cnLevels = (/0.0,0.025,0.05,0.075,0.1,0.15,0.2,0.3,0.4, 0.5, 0.6, 0.7, 0.8, 0.9,1./)
   res@lbLabelStrings = (/0.0,0.025,0.05,0.075,0.1,0.15,0.2,0.3,0.4, 0.5, 0.6, 0.7, 0.8, 0.9,1./)

;---------------------------------------------
;  HERE IS WHERE YOU STRIDE THE DATA AND PLOT LATITUDE AND LONGITUDE ON X-AXIS
;---------------------------------------------
   res@tmXTOn = False
   res@tmXBMode = "Explicit"
   res@tmXBValues = xcoord(::stride)
   res@tmXBLabels = xlabel(::stride,0)
   res@tmXBLabelFontHeightF = 0.01

;---------------------------------------------
;  HERE YOU CAN SET A MAXIMUM ALTITUDE
;---------------------------------------------
   res@trYMaxF = 20  ; THIS IS IN KILOMETERS

;---------------------------------------------
;  HERE, SET SPECIAL LABEL HEIGHTS AND ORIENTATION
;---------------------------------------------
   res@lbLabelFontHeightF = 0.01
   res@lbLabelAngleF = 0.0
   res@lbOrientation = "vertical"
   res@vpWidthF = 1.0
  
;---------------------------------------------
;  PLOT
;---------------------------------------------
   res@gsnDraw = True
   res@gsnFrame = False
   plot = gsn_csm_contour(wks,depol,res)
   frame(wks)

;---------------------------------------------
;  TO REPEAT THE LOOP, THE FOLLOWING MUST BE REMOVED
;  If using 6.2.0, use the := syntax
;---------------------------------------------
delete([/tot, perp, depol, depol1, lat, lon, xlabel \
       , time, tstring, xcoord/]) 

end do
end

