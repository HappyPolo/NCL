;***********************************************
; csv_6.ncl
;
; Concepts illustrated:
;   - Reading a CSV file
;   - Using str_match_ic_regex to extract lines (rows)
;   - Writing the selected information to an ascii file
;
;***********************************************
; input data

  diri   = "./"
  fkey   = "479615"
  flnm   = fkey+".NorthDakota.csv"
  strs   = asciiread(diri+flnm,-1,"string")

; user specified KEY string

  strkey = "CROSBY"
  
; find all lines (rows) which contain the key string

  seldata = str_match_ic_regex(strs, strkey)     ; 6.3.0  onward
  print(seldata)
  
; write an ascii file with selected information
; remove any pre-existing file

  seldir  = "./"
  selfil  = fkey+"."+strkey+".csv"
  system("/bin/rm -f "+seldir+selfil)
  
  asciiwrite(fkey+"."+strkey +".csv", seldata)   ; all data for selected yyyymm

