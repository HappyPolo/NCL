begin
  infile = "test-with-missing.csv"
  lines  = asciiread (infile, -1, "string")  ; -1 means read whole file
  print(lines)                               ; echo input

  strs   = str_split_csv (lines, ",", 0)    
  nums   = tofloat (strs)                    ; _FillValue = 9.96921e+36
  nums@_FillValue = -9999.0                  ; change to 'nicer' _FillValue
  
;;print("---")
;;print(strs + "      " + nums)              ; side-by-side string ===> numeric

  print("---")
  print(nums(:,0) + "   " + nums(:,1))
  
end

