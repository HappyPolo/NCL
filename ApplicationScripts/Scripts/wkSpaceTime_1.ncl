load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"

;==================================================================
;                     USER INTERFACE 
;                   MAIN DRIVER SCRIPT
;==================================================================
  case     = "Example_1"
  diro     = "./"     ; output dir: location of plots  [wkdir]

  latBound = 15

  level    = -999     ; only used for 4D [set -999 otherwise]

  VAR      = "olr"    
  spd      = 2        ; olr    
  diri     = "/project/cas/shea/WHEELER/JET_WK/"
  fili     = "OLR.12hr_2yrs.wheeler.nc"             ; newly formatted file

  nDayWin  = 96      ; Wheeler-Kiladis [WK] temporal window length (days)
  nDaySkip = -65     ; time (days) between temporal windows [segments]
                     ; negative means there will be overlapping temporal segments
  opt      = False

  wkSpaceTime_cam( diri        \ ; input directory
                 , fili        \ ; input file
                 , diro        \ ; output directory [plots]
                 , case        \ ; case name
                 , VAR         \ ; variable name
                 , latBound    \ ; NH lat bound [positive]
                 , spd         \ ; samples per day
                 , level       \ ; if 4D ... what level? set -999 if 3D
                 , nDayWin     \ ; temporal window length [days]
                 , nDaySkip    \ ; days between time windows 
                 , opt         \ ; options .... 
                 )
