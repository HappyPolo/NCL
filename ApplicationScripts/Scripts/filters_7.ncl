; *********************************************
; filters_7.ncl
; *********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    

begin
  pltDir  = "./"
  pltType = "png"                       ; send graphics to PNG file
  pltName = "filters"

;  diri  = "/Users/shea/Data/AMWG/"
  diri  = "./"
  vName = "U_anom"        ; name of variable on the file
  fili  = "uwnd.day.850.anomalies.1980-2005.nc"
  f     = addfile(diri+fili, "r")

  time  = f->time
  date  = cd_calendar(time,-2)          ; yyyymmdd
  ntim  = dimsizes(time)                ; all times

  X     = f->$vName$(:,{0},{120})       ; entire series
  delete(X&time)
  X&time= date                          ; yyyymmdd

  yrfrac= yyyymmdd_to_yyyyfrac (date, 0)
  delete(yrfrac@long_name)

; ***********************************************
; create the filter weights and apply
; ***********************************************
  ihp     = 2                             ; band pass
  sigma   = 1.0                           ; Lanczos sigma

  nWgt    = 201                           ; loose 100 each end  
  fca     = 1./50.                        ; start freq
  fcb     = 1./10.                        ; last  freq
  wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )
  xbpf    = wgt_runave_Wrap ( X, wgt, 0 )      ; entire series

; ***********************************************
; decimate the series by taking ever 3rd value usin NCL symtax ::3
; generate new weights
; ***********************************************
  nWgt3   = 67                            ; loose mWgt/2 each end  
  fca     = 3./50.                        ; start freq
  fcb     = 3./10.                        ; last  freq
  WGT3    = filwgts_lanczos (nWgt3, ihp, fca, fcb, sigma )
  XBPF3   = wgt_runave_Wrap ( X(::3), WGT3, 0 ) ; decimate entire series
  NTIM    = dimsizes(XBPF3)
  YRFRAC  = yrfrac(::3)

; ***********************************************
; Find index values corresponding to 1996-1997
; ***********************************************

  pStrt = 1996      ;  winter 96-97 MJO gold standard
  pLast = 1997      ; years to plot

  yyyy  = xbpf&time / 10000
  ii    = ind(yyyy.ge.pStrt .and. yyyy.le.pLast)   

  YYYY  = XBPF3&time / 10000
  jj    = ind(YYYY.ge.pStrt .and. YYYY.le.pLast)   

; ***********************************************
; plot
; ***********************************************
  pltPath = pltDir+pltName
  wks     = gsn_open_wks (pltType,pltPath)

  res              = True            ; plot mods desired
  res@gsnFrame     = False
  res@gsnMaximize  = True
  res@gsnPaperOrientation  = "portrait"

  res@vpHeightF    = 0.4             ; change aspect ratio of plot
  res@vpWidthF     = 0.8                  
  res@vpXF         = 0.1             ; start plot at x ndc coord 
  res@gsnYRefLine  = 0.0             ; create a reference line   
  res@xyMonoDashPattern = True
  res@xyLineThicknessF  = 2
  res@xyLineColors      = "blue"

  res@tiMainString   = "Band Pass Filtered: 10-50 day"     
  res@gsnCenterString = "blue all days [N="+nWgt+"], red sub-sample [N="+nWgt3+"]"     
  plot = gsn_csm_xy (wks,yrfrac(ii),xbpf(ii),res)     
     
  polyres                  = True
  polyres@gsLineThicknessF = 2
  polyres@gsLineColor      = "red"
  gsn_polyline(wks,plot,YRFRAC(jj),XBPF3(jj),polyres) ; add polyline
  frame(wks)
end

