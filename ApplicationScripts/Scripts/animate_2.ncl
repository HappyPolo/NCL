;======================================================================
; animate_2.ncl
;
; Concepts illustrated:
;   - Creating animations
;   - Animating WRF data
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;======================================================================
; The main code
;======================================================================

begin
;---Read desired data
    srcFileName = "WRF.grb"
    sfile = addfile(srcFileName,"r")

    TMP       = sfile->TMP_GDS5_ISBL
    TMP@lat2d = sfile->g5_lat_0     ; for plotting
    TMP@lon2d = sfile->g5_lon_1
    printVarSummary(TMP)

;---For zooming in on map
    minlat =  53.0
    maxlat =  88.0
    minlon = 175.0
    maxlon = 235.0

;---Get dimensions
    dims  = dimsizes(TMP)
    nlev  = dims(0)
    nlat  = dims(1)
    nlon  = dims(2)


;---Set some resources
    res                   = True

    res@gsnMaximize       = True

    res@cnFillOn          = True
    res@cnLinesOn         = False
    res@cnLineLabelsOn    = False

    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels             = ispan(200,293,3)
    res@cnFillPalette        = "WhViBlGrYeOrReWh"

    res@mpMinLatF         = minlat 
    res@mpMaxLatF         = maxlat 
    res@mpMinLonF         = minlon 
    res@mpMaxLonF         = maxlon 

    res@mpCenterLonF      = (minlon+maxlon)*0.5
    res@mpCenterLatF      = (minlat+maxlat)*0.5

    res@pmTickMarkDisplayMode = "Always"

    res@lbLabelFontHeightF    = 0.01

    res@gsnAddCyclic      = False       ; this is regional data

;---Loop across each level and plot to a different PNG file every time
    do n=0,nlev-1
      wks = gsn_open_wks("png","animate"+sprinti("%02i",n))    ; animate_00.png, animate_01.png, etc

      print("level(" + n + ") = " + TMP&lv_ISBL2(n))

      res@gsnRightString  = "level = " + TMP&lv_ISBL2(n) + " (" + TMP&lv_ISBL2@units + ")"

      plot = gsn_csm_contour_map(wks,TMP(n,:,:),res)  

      delete(wks)   ; Make sure PNG file is closed
    end do

;---Convert PNG images to animated GIF
    cmd = "convert -delay 25 animate*.png animate_2.gif"
    system(cmd)
end
