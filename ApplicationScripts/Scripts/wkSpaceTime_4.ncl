load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"

  case     = "TRMM 200001-200912"  
  diro     = "./" 

  latN     = 15
  latS     = -latN       ; symmetric about the equator

  nDayWin  = 96      ; Wheeler-Kiladis [WK] temporal window length (days)
  nDaySkip = 15      ; time (days) between temporal windows [segments]
                     ; negative means there will be overlapping 
                     ; temporal segments

  opt      = True
  opt@debug= True
  opt@pltType     = "eps"
  opt@cnLinesOn   = False   ; turn off contour lines
                     ; specify the plot intervals

  spd      = 1       ; samples per day 
  var      = "precip"  ; user specified 

  diri     = "./"
  fili     = systemfunc("cd "+diri+" ; ls 3B42.200[0-9]*.day.nc")
 ;print(fili)

  f        = addfiles (diri+fili, "r") 
  VAR      = f[:]->precip(:,{latS:latN},:)    ; extract desire latitude band

  printVarSummary(VAR)

  nMsg     = num(ismissing(VAR))  ; check for _FillValue
  if (nMsg.gt.0) then
      print("missing values present: not allowed: nMsg="+nMsg) 
      exit
  end if
 
                     ; calculation and create plots
  wkSpaceTime (VAR, diro, case, var             \
              ,latN, spd, nDayWin, nDaySkip, opt  )

