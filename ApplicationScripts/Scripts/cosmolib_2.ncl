;----------------------------------------------------------------------
; cosmolib_2.ncl
;
; Concepts illustrated:
;   - Plotting COSMO model data from MeteoSwiss
;   - Plotting data from a rotated lat-lon grid
;   - Using functions from COSMOlib 
;----------------------------------------------------------------------
; To learn more about COSMOlib, visit: 
;   https://wiki.c2sm.ethz.ch/Wiki/VisNCLCosmoLibrary
;----------------------------------------------------------------------
begin

 ; open file
 fname = "lfff01000000"
 cname = "lfff00000000c"
 ftype = "grb"
 lfile = addfile(fname+"."+ftype,"r")
 cfile = addfile(cname+"."+ftype,"r")

 ; read water vapour and level height
 qv3d = jmb_getvar(lfile, "QV", False)

 ; geo-reference
 jmb_getgrid(lfile, cfile, qv3d, False)

 ; close files
 delete(cfile)
 delete(lfile)

 ; slice at constant rotated latitude
 jval  = 147 ; rotated latitude index for cross-section
 qv = jmb_slice(qv3d, "j", jval, False)
 delete(qv3d)
 
 ; convert units
 qv = 1000.0 * qv  ; g/kg
 qv@unit = "g kg-1"
 qv@z = qv@z / 1000.0
 qv@level_height_units = "km"

 ; open graphic port
 ptype = "png"                                 ; send graphics to PNG file
 wks = gsn_open_wks(ptype,"cosmolib")

 ; set color table
 rc = jmb_set_ct(wks, "precip_11lev", False)

 ; setup irregular mesh
 res                        = rc
 res@trYMinF                = 0.0
 res@trYMaxF                = 10.0

 ; setup contour plot resources
 res@vpWidthF               = 0.85
 res@vpHeightF              = 0.5
 res@gsnMaximize            = True             ; maxmize plot in frame
 res@cnLevelSelectionMode   = "ManualLevels"   ; manual level selection
 res@cnMinLevelValF         = 0.0              ; water (blue) is below 0.0m
 res@cnMaxLevelValF         = 5.0           ; snow/ice (white) is at 3000.0m
 res@pmTickMarkDisplayMode  = "conditional"

 ; make contour
 cn = jmb_contour(wks, qv, res)
 delete(res)

 ; make plot
 pl = jmb_overlays(wks, (/cn/), False)

 ; cleanup
 delete(wks)

end
