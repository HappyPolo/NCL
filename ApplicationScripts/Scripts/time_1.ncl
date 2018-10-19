;***************************************************************
; time_1.ncl
;
; Concepts illustrated:
;   - Creating an integer yyyymm given a start and last year
;   - Formatting integers using "sprinti"
;   - Create a udunits recognized time variable
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin                                                 ; optional

  yrStrt     = 1998
  yrLast     = 2001

; Create a yyyymm variable (integer and string)

  yyyymm     = yyyymm_time(yrStrt, yrLast, "integer") ; contributed.ncl
  yyyymm_s1  = tostring( yyyymm )                     ; method 1     
  yyyymm_s2  = sprinti("%6i",yyyymm)                  ; method 2

; Create a yyyy.fraction_of_year variable. Useful for graphics

  yrfrac     = yyyymm_to_yyyyfrac(yyyymm, 0.0)

; Create a time variable of the form 'seconds/hours/days since ...'

  ntim       = dimsizes(yyyymm)

  yyyy       = yyyymm/100
  mm         = yyyymm - (yyyy*100)

  dd         = conform_dims(ntim, 0, -1)         ; replicate scalar to all dimensions
  hh         = conform_dims(ntim, 0, -1)
  mn         = conform_dims(ntim, 0, -1)
  sc         = conform_dims(ntim, 0, -1)

  tunits     = "hours since 1900-01-01 00:00:00" ; "seconds/hours/days since ...."
                                                 ; do NOT use "months since ...."

  time       = cd_inv_calendar(yyyy,mm,dd,hh,mn,sc,tunits, 0)
  time!0     = "time"

  print(yyyymm+"  "+yyyymm_s1+"  "+yyyymm_s2+"   "+time+"   "+yrfrac)

end                                                   ; only if 'begin' is present


