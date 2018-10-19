
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  ; This library is automatically loaded
                                                               ; from NCL V6.2.0 onward.
                                                               ; No need for user to explicitly load.
;===================== NCDC.Central_Iowa.1895-2016.txt============================================== 
;============================ First two lines =======================================================        
;StateCode Division YearMonth     PCP    TAVG    PDSI    PHDI    ZNDX    PMDI     CDD     HDD    SP01    SP02    SP03    SP06    SP09    SP12    SP24    TMIN    TMAX 
;      110       00    189501    3.32   26.69    1.47    1.47    4.42    1.47       6    1017    1.79  -99.99  -99.99  -99.99  -99.99  -99.99  -99.99   16.52   36.86
;====================================================================================================
  diri = "./"
  fili = "NCDC.Central_Iowa.1895-2016.txt"
  pthi = diri+fili

;---Given the # of columns, we can use readAsciiTable to read this file.
  ncol   = 20
  data   = readAsciiTable(pthi,ncol ,"float",1)
  data@_FillValue = -99.99        ; set _FillValue

;---Extract specifiv variables for clarity
  yyyymm = toint(data(:,2))
  ntim   = dimsizes(yyyymm)       ; number of dates (times)        

  pcp    = data(:,3)              ; inches
  tavg   = data(:,4)              ; Farenheit
  pdsi   = data(:,5)
  tmin   = data(:,ncol-2)         ; Farenheit
  tmax   = data(:,ncol-1)         ; Farenheit

