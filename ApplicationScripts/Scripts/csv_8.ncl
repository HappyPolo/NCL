;***********************************************
; csv_8.ncl
;
; Concepts illustrated:
;   - Reading CSV file via 'asciiread'
;   - Using str_match_ic_regex to extract lines (rows)
;     Here: all lines that contain the string matching 'keystr'
;   - Writing the selected information to an ascii file
;   - Find the user specified 'fldstr' and extract the time series values
;   - Plot the random data.
;***********************************************
; input data
;***********************************************

  diri   = "./"
  fkey   = "479615"
  flnm   = fkey+".NorthDakota.csv"
  strs   = asciiread(diri+flnm,-1,"string")

;***********************************************
; user specified YYYYMM and VARIABLE
;***********************************************

  keystr = "WILLISTON"
  fldstr = "MMXT"                                              ; case sensitive
  con    = 0.10  

;***********************************************
; match all data with specified YYYYYY
;***********************************************

  seldata = str_match_ic_regex(strs, keystr)    ; 6.3.0  
;;print(seldata)
  print("=====")

;***********************************************
; write selected data to ascii file
;***********************************************
  
  seldir  = "./"
  selfil  = fkey+"."+keystr+".csv"
  system("/bin/rm -f "+seldir+selfil)
  asciiwrite(seldir+selfil, seldata)   ; all data for selected yyyymm

;***********************************************
; Which field matches
;***********************************************

  FIELDS = (/"STATION","STATION_NAME","DATE","CLDD","DPNP","DPNT","HTDD"    \
            ,"DT90","DX32","DT00","DT32","DP01","DP05","DP10","EMXP","MXSD" \
            ,"DSNW","TPCP","TSNW","EMXT","EMNT","MMXT","MMNT","MNTM"        /)

  nfield = ind(FIELDS.eq.fldstr) + 1      ; field to be extracted   
  print("fldstr="+fldstr+" corresponds to field number "+nfield)
  print("=====")

;***********************************************
; extract the station name, yyyymm and values for the specified field
;***********************************************

  sdat   = str_get_field(seldata , 2, ",")                      ; station name
  yyyymm = toint(str_get_field(seldata , 3, ","))               ; yyyymm   ame
  data   = tofloat( str_get_field(seldata , nfield, ",") )*con  ; variable values
  data@_FillValue = -9999*con 
  print(sdat+" : "+yyyymm+" : "+data)
  print("=====")

;***********************************************
; plot
;***********************************************
; convert yyyymm to fractions for plotting
;***********************************************
  yrFrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)

  pltDir = "./"
  pltNam = fkey+"_NorthDakota_"+fldstr+"_"+keystr
  pltTyp = "ps"

  wks = gsn_open_wks(pltTyp,pltDir+pltNam)
 ;gsn_define_colormap(wks,"WhViBlGrYeOrRe")

  res                 = True
  res@gsnMaximize     = True
  res@vpHeightF       = 0.4                   ; change aspect ratio of plot
  res@vpWidthF        = 0.8                  
  res@trXMinF         = min(yrFrac)-1
  res@trXMaxF         = max(yrFrac)+1
  res@gsnCenterString             = keystr+": "+fldstr
  map = gsn_csm_xy(wks,yrFrac,data,res)
