load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"

;==================================================================
;                     USER INTERFACE 
;                   MAIN DRIVER SCRIPT
;==================================================================
  case     = "Example_2"
  diro     = "./"     ; output dir: location of plots 


  VAR      = "U200"
  diri     = "/project/cas/shea/WHEELER/"
  fili     = "u.200.1999-2001.nc"

  nDayWin  = 96       ; Wheeler-Kiladis [WK] temporal window length (days)
  nDaySkip = -65      ; time (days) between temporal windows [segments]
                      ; negative means there will be overlapping temporal segments
  latBound = 15       ; 15N lat 

                      ; get data 
  f        = addfile (diri+fili, "r")
  u        = f->$VAR$(:,{latBound:-latBound},:)   ; [time | 4384] x [lat | 22] x [lon | 256]
  spd      = 4        ; original data is 4 samples per day
                   

  opt      = True
  opt@debug       = True   
  opt@pltType     = "eps"        ; create encapsulated postscript
  opt@pltColorMap = "amwg"       ; change the default color map
  opt@spdSkip     = 2            ; decimate to two samples per day 

  wkSpaceTime (u,  diro, case, VAR             \
              ,latBound, spd , nDayWin, nDaySkip, opt  )
