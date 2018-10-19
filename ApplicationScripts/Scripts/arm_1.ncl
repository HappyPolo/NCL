;*************************************************
; arm_1.ncl           
;
; Concepts illustrated:
;   - Read sample ARM datafile from the 'swfcldgrid' suite of files
;   - Add udunits recognized attribute to variable
;   - Plot time and space averages
;   - Drawing time-variable time series
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
  diri  = "./"
  fili  = "sgp15swfcldgrid1longN1.c1.20091021.140000.cdf"

;*********************************************
; read data & quality flags 
;*********************************************
  f     = addfile(diri+fili,"r")
  x     = f->cloudfraction                   ; (time, lat, lon)
  xqc   = f->qc_cloudfraction                ; packed integer; 0 means good 
  timeo = f->time_offset                     ; Time offset from base_time
                                             ; seconds since ...
  printMinMax(x&lat, True)               
  printMinMax(x&lon, True)

;*********************************************
; Change lat/lon units to udunits compatible
;*********************************************
  x&lat@units = "degrees_north"
  x&lon@units = "degrees_east"

;*********************************************
; Use the quality flags to eliminate 'bad' values
; Basically, any non-zero value.
;*********************************************
  x      = mask(x, xqc.ne.0, False)

;*********************************************
; [1] Use 'stat_dispersion' for crude data exploration
; [2] Spatial average each time. No spatial wgting. Small area.
; [3] Temporal average at each grid point
;*********************************************

  opt = True                                 ; [1]
  opt@PrintStat = True
  xStat = stat_dispersion(x, opt )

  xAvgSpace = dim_avg_n_Wrap(x, (/1,2/))     ; [2]  xAvgSpace(time)
  printVarSummary(xAvgSpace)

  xAvgTime  = dim_avg_n_Wrap(x, 0      )     ; [3]  xAvgTime(lat,lon)
  printVarSummary(xAvgTime)

;************************************************
; plotting parameters
;************************************************
 wks   = gsn_open_wks ("png","arm")              ; send graphics to PNG file

 res                  = True                     ; plot mods desired
 res@tiMainString     = fili
 res@gsnCenterString  = f->base_time@string
 plot  = gsn_csm_xy (wks,timeo,xAvgSpace,res)    ; create plot

 delete(res@gsnCenterString)                     ; do not want

 res@mpMinLatF        = min(xAvgTime&lat)
 res@mpMaxLatF        = max(xAvgTime&lat)
 res@mpMinLonF        = min(xAvgTime&lon)
 res@mpMaxLonF        = max(xAvgTime&lon)
 res@pmTickMarkDisplayMode = "Always"

 res@cnFillOn         = True                     ; color
 res@cnFillPalette    = "amwg"                   ; set color map
 res@mpFillOn         = False
 res@gsnAddCyclic     = False                    ; array not global

 plot  = gsn_csm_contour_map_ce (wks,xAvgTime,res) ; create plot
end
 
