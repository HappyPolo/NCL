
; ==============================================================
; POPanalysis: Calculate POPs
;              This is a user donated script.
;             *It is NOT supported software.
; ==============================================================
; Calculate POPs from SST data
; ==============================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "./PrnOscPat_driver.ncl"    ; creates the POPs from EOFs
load "./TEST/pltEofPop.ncl"      ; plot EOF/POP
load "./TEST/pltClim.ncl"        ; plot climatology

; ==============================================================
;                      MAIN 
; ==============================================================

  wcStrt = systemfunc("date")

  netCDF  = True                        ; create nc for POP
  dirNC   = "./"                        ; dir for output nc

  pltDir  = "./"                        ; dir for plots
  pltEOF  = True
  pltPOP  = True
  pltCLIM = True   
  
  pltType = "ps"
  pltName = "POP"

; ==============================================================
; User defined parameters that specify region of globe and time period
; ==============================================================

  latS   = -40.				; spatial domain
  latN   =  40. 
  lonL   =  45.
  lonR   = 285.	
   
  kPOP   = 1				; decide which POP we want to look at
  POPphase = (/"precursor","peak"/)	; (/ 0, 1/)	

  yrStrt = 1850
  yrLast = 2011

  neof   = 10                           ; number of EOFs 
  nPOP   = 2	                        ; number of POPs

  optEOF = True       
  optETS = False
                               
  REDUCE = False                         ; reduce spatial density
  nskip  =  2                            ; only when REDUCE=True
  mskip  =  2

; ==============================================================
; Open the file
; ==============================================================
  patho  = "./"                                         ; path for output  

  pathi  = "./"                                         ; path to source 
  ifile  = "HadISST_sst.nc"

  varname= "sst"					; variable name 
  f      = addfile (pathi+ifile, "r")			; entire file

; ==============================================================
; Read only the user specified period and region
; ==============================================================

  TIME   = f->time                                      ; ALL time on file
  YYYY   = cd_calendar(TIME,-1)/100			; ALL years
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast) 	; indices of year subset
  nTIME  = dimsizes(iYYYY)
                                                        ; read full year subset 
  if (getfilevartypes(f, varname).eq."short") then      ; clarity
      DATA = short2flt(f->$varname$(iYYYY,{latS:latN},:))         
  else
      DATA = f->$varname$(iYYYY,{latS:latN},:)
  end if

  printVarSummary(DATA)                            	; variable overview

; ==============================================================
; If dataset longitudes are -180=>180, flip to (nominally) span 0=>360   
; Only if both'lonL' and 'lonR' are positive.
; ==============================================================
  if (lonL.ge.0 .and. lonR.gt.0 .and. DATA&lon(0).lt.0) then
      DATA    = lonFlip(DATA)				; flip longitudes 
     ;printVarSummary(DATA)  
  end if

; ==============================================================
; Subset to the time period (full years) and region of interest
; Optionally: reduce the grid point density for less memory.
; ==============================================================
  if (REDUCE) then
      data  = DATA(:,::nskip,{lonL:lonR:mskip}) 
  else
      data  = DATA(:,:,{lonL:lonR}) 
  end if
  delete(DATA)                                         ; reduce memory

  printVarSummary(data)                                ; data to be used
  
; ==============================================================
; Remove annual cycle from the data: create anomalies
; .  use only full years to find annual cycle
; ==============================================================  
  clim  = clmMonTLL(data)				; calculcate climatology
 ;printVarSummary(clim)

  data 	= calcMonAnomTLL(data, clim)			; remove annual cycle
 ;printVarSummary(data)                              	; variable overview

  ntim  = dimsizes(data&time)			

; =================================================================
; remove linear trend in time:  data(time,lat,lon): time is dimension # 0)
; =================================================================
  data = dtrend_n(data, False, 0)

; =================================================================
; normalize data at each gridpoint by local standard deviation at each grid pt
; =================================================================
  data = dim_standardize_n(data,1,0)

; =================================================================
; low pass (lp) filter 
; remove short time scale variance (everything shorter than 18 months)
; =================================================================
  ihp   = 0						; lowpass filter
  sigma = 1
  nWgt  = 37						; loose 18 months each end
  fca   = 1./18.					; 18 months
  wgt 	= filwgts_lanczos(nWgt,ihp,fca,data@_FillValue,sigma)
  datalp= wgt_runave_n_Wrap(data,wgt,0,0)               ; running average (time)
  datalp@long_name = "Low Pass: "+data@long_name
  printVarSummary(datalp)                               ; (time,lat,lon)

; =================================================================
; Reorder (lat,lon,time) the input data so time is rightmost dimension.
; This is the order expected by the 'eofunc'
; =================================================================

  xlp   = datalp(lat|:,lon|:,time|:)    
  delete(datalp)                                        ; no longer needed
; =================================================================
; find EOFs: no weighting is performed here due to limited lat range 
; =================================================================

  eof    = eofunc_Wrap(xlp, neof, optEOF)      	        ; find first neof EOFs
  eof_ts = eofunc_ts_Wrap (xlp, eof, optETS)		; time series
  
  printVarSummary( eof )				; examine EOF variables
  printVarSummary( eof_ts )

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; A driver for the POP matrix operations.       
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  pop_results  = PrnOscPat_driver(eof, eof_ts, kPOP)   ; returns a list 
  print(pop_results)                                   ; containing variables
   
; =================================================================
; For convenience & clarity extract each of the two elements 
;     and place them into separate variables reather than acces
;     via 'list' syntax.
; =================================================================
             
  pop_ts    = pop_results[0]     ; POP time series  (nEOF,time)
  printVarSummary(pop_ts)
 ;print("pop_ts: min="+min(pop_ts)+"   max="+max(pop_ts))

  pop_pat   = pop_results[1]     ; POP patterns     (nEOF,lat,lon)
  printVarSummary(pop_pat)
 ;print("pop_pat: min="+min(pop_pat)+"   max="+max(pop_pat))

  delete(pop_results)            ; no longer needed

; ===========================================================
; Miscellaneous for file creation and plots
; ===========================================================
  sfx    = get_file_suffix(ifile, 0)
  froot  = sfx@fBase 

  yyyymm = cd_calendar(eof_ts&time,-2)/100  
  yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)   

  yyyymm!0 = "time"
  yrfrac!0 = "time"
  yyyymm&time = eof_ts&time
  yrfrac&time = eof_ts&time

if (netCDF) then
; ===========================================================
; NETCDF: write POP data to file: Use simple method of writing netCDF
; ===========================================================

  pathNC = dirNC+"POP_"+froot+".nc" 
  system("/bin/rm -f " + pathNC)    ; remove file if exists
  fout = addfile(pathNC,"c")
  setfileoption(fout,"DefineMode",True)

; create global attributes
  fileAtt		= True
  fileAtt@creation_date = systemfunc("date")
  fileattdef(fout,fileAtt)

  fout->yyyymm      = yyyymm    
  fout->yrfrac      = yrfrac    
  fout->POP_TS      = pop_ts
  fout->POP_PATTERN = pop_pat

  fout->EOF_TS      = eof_ts
  fout->EOF         = eof
end if

;============================================================
; PLOTS
;============================================================

if (pltEOF) then
  pltEofPop(eof_ts, eof, yrfrac, froot, pltType, "EOF", "BlueYellowRed")
end if    ; pltEOF

if (pltPOP) then
  pltEofPop(pop_ts, pop_pat, yrfrac, froot, pltType, "POP", "BlueYellowRed")
end if    ; pltPOP

if (pltCLIM) then
    pltClim(clim, froot, pltType, "CLIM", "BlAqGrYeOrReVi200")
end if    ; pltCLIM


wallClockElapseTime(wcStrt, "POPanalysis", 0)
