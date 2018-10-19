load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"

  case     = "NCEP: 2001-2005:"  
  diro     = "./"        ; output dir: location of plots 

  latN     = 15
  latS     = -latN       ; symmetric about the equator

  nDayWin  = 96      ; Wheeler-Kiladis [WK] temporal window length (days)
  nDaySkip = 30      ; time (days) between temporal windows [segments]
                     ; negative means there will be overlapping 
                     ; temporal segments

  opt      = True
  opt@debug= True
  opt@pltType     = "eps"
  opt@cnLinesOn   = False   ; turn off contour lines
                     ; specify the plot intervals

  spd      = 4       ; samples per day (6 hour sampling rate)
  var      = "OMEGA500"  ; user specified 

  diri     = "/project/cas/shea/WHEELER/"
  fili     = "OMEGA.2001-2005.nc"    

  f        = addfile (diri+fili, "r") 
  omega    = f->omega(:,0,{latS:latN},:)     ; (time,lat,lon)

                     ; calculation and create plots
  wkSpaceTime (omega, diro, case, var             \
              ,latN, spd, nDayWin, nDaySkip, opt  )
