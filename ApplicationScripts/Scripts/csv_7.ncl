;***********************************************
; csv_7.ncl
;
; Concepts illustrated:
;   - Reading two CSV files via 'asciiread'
;     One contains the data values
;     The other contains the lat/lon locations
;   - Using str_match_ic_regex to extract lines (rows)
;     Here: all lines that contain the 'yyyymm'
;   - Writing the selected information to an ascii file
;   - Find the user specified 'fldstr' and extract the values
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

  yyyymm = 197504
  fldstr = "DPNT"                                         ; case sensitive
  con    = 1.00  

;***********************************************
; match all data lines with specified YYYYYY
;***********************************************

  seldata = str_match_ic_regex(strs, tostring(yyyymm))    ; 6.3.0  
  print(seldata)
  print("=====")

;***********************************************
; write selected data to ascii file
;***********************************************
  
  seldir  = "./"
  selfil  = fkey+"."+yyyymm+".csv"
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
; extract the values
;***********************************************

  sdat   = str_get_field(seldata , 2, ",")
  data   = tofloat( str_get_field(seldata , nfield, ",") )*con
  data@_FillValue = -9999*con 
  print(sdat+" : "+data)
  print("=====")

;***********************************************
; station locations: 2nd ascii file
;***********************************************

  strll  = asciiread(diri+fkey+".latlon.csv", -1, "string") ; 
  print(strll)   ; STATION","STATION_NAME", "LAT", "LON"
  print("=====")

  sloc = str_get_field(strll , 2, ",") 
  lat  = tofloat( str_get_field(strll , 3, ",")  )
  lon  = tofloat( str_get_field(strll , 4, ",")  )
  print(sloc +" : "+lat+" "+lon)
 
  pltDir = "./"
  pltNam = fkey+"_NorthDakota_"+fldstr+"_"+yyyymm
  pltTyp = "ps"

;***********************************************
; Plot
;***********************************************
  wks = gsn_open_wks(pltTyp,pltDir+pltNam)
 ;gsn_define_colormap(wks,"WhViBlGrYeOrRe")

  res                             = True
  res@gsnFrame                    = False   ; So we can draw markers
  res@gsnMaximize                 = True

  res@pmTickMarkDisplayMode       = "Always"
  res@trGridType                  = "TriangularMesh"    ; The default if you

  res@mpMinLatF                   = 45.8     ; range to zoom in on
  res@mpMaxLatF                   = 49.1
  res@mpMinLonF                   = -104.2
  res@mpMaxLonF                   = -96.5
  res@mpOutlineBoundarySets= "USStates"

 ;res@cnLevelSelectionMode        = "ManualLevels"
 ;res@cnMinLevelValF              = 
 ;res@cnMaxLevelValF              =
 ;res@cnLevelSpacingF             =

  res@cnFillOn                    = True
  res@cnLinesOn                   = True
  res@cnLineLabelsOn              = True

  res@sfXArray                    = lon
  res@sfYArray                    = lat

  res@gsnCenterString             = fldstr+": "+yyyymm 
  map = gsn_csm_contour_map(wks,data,res)

;
; Draw markers on the plot in the lat/lon locations.
;
  mkres               = True
  mkres@gsMarkerIndex = 16     ; Filled circle
  mkres@gsMarkerSizeF = 0.03

  gsn_polymarker(wks,map,lon,lat,mkres)

  frame(wks)
  
