; **********************************************
; filters_3.ncl
; **********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
begin

;  diri    = "/Users/shea/Data/AMWG/"
  diri    = "./"
  vName   = "U_anom"        ; name of variable on the file
  fili    = "uwnd.day.850.anomalies.1980-2005.nc"
  f       = addfile(diri+fili, "r")
  x       = f->$vName$(:,{0},{120})

; ***********************************************
; create the filter weights and apply
; ***********************************************

  ihp     = 2                             ; band pass
  sigma   = 1.0                           ; Lanczos sigma

  nWgt    = 201                           ; loose 100 each end                            
  fca     = 1./100.                       ; start freq
  fcb     = 1./20.                        ; last  freq
  wgt     = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )
  printVarSummary(wgt)
  xBPF    = wgt_runave ( x, wgt, 0 )      ; 20-100 day
  printVarSummary(xBPF)

; ***********************************************
; create new date array for use on the plot
; ***********************************************

  date    = cd_calendar(x&time,-2)        ; yyyymmdd
  yrfrac  = yyyymmdd_to_yyyyfrac (date, 0)
  delete(yrfrac@long_name)
  delete(x@long_name)

  pStrt = 19950101      ; 4 years: winter 96-97 MJO gold standard
  pLast = 19981231
  iStrt = ind(date.eq.pStrt)        ; user specified dates
  iLast = ind(date.eq.pLast)
  delete(date)

  pltType = "png"                    ; send graphics to PNG file
  pltName = "filters"
  plot    = new ( 2, "graphic") 
  wks     = gsn_open_wks (pltType,pltName)

  res              = True            ; plot mods desired
  res@gsnDraw      = False           ; don't draw 
  res@gsnFrame     = False           ; don't advance frame yet      

  res@vpHeightF    = 0.4             ; change aspect ratio of plot
  res@vpWidthF     = 0.8                  
  res@vpXF         = 0.1             ; start plot at x ndc coord 
  res@gsnYRefLine  = 0.0             ; create a reference line   
  
  res@gsnCenterString = "Anomaly U [0, 100E]" 
  res@tmXBFormat = "f"
  plot(0) = gsn_csm_xy (wks,yrfrac(iStrt:iLast),x(iStrt:iLast),res)      
  
  res@gsnCenterString  = "Band Pass Filtered: 20-100 day"     
  plot(1) = gsn_csm_xy (wks,yrfrac(iStrt:iLast),xBPF(iStrt:iLast),res)     
  
  resP                 = True    
  resP@gsnMaximize     = True
  gsn_panel(wks,plot,(/2,1/),resP) 

  ; Create XY plot of frequency versus response

  xyres = True

  xyres@gsnMaximize    = True
  xyres@gsnFrame       = False
  xyres@tiMainString   = "Band Pass: 20-100 srate=1: sigma = " + sigma
  xyres@tiXAxisString  = "frequency"
  xyres@tiYAxisString  = "response"
  xyres@gsnLeftString  = "fca=" + fca + "; fcb=" + fcb
  xyres@gsnRightString = nWgt
  xyres@trXMaxF        = 0.1
  xyres@trYMaxF        = 1.1
  xyres@trYMinF        = -0.1

  plot = gsn_csm_xy(wks, wgt@freq, wgt@resp, xyres)

  X = (/0.0, fca, fca, fcb, fcb, 0.1/)      ; ideal filter
  Y = (/0.0, 0.0, 1.0, 1.0, 0.0,  0.0 /) 

  resGs = True
  resGs@gsLineThicknessF = 1.0

  gsn_polyline(wks,plot,X,Y,resGs)

  frame(wks)
end

