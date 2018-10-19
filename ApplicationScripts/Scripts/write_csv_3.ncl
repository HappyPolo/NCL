;----------------------------------------------------------------------
; write_csv_3.ncl
;
; Concepts illustrated:
;   - Writing a CSV file with a header using write_table
;   - Writing data of mixed types to a CSV file
;----------------------------------------------------------------------
; The CSV file created by this script should look like this:
;
;   "ID","LAT","LON","ELEV","SOURCE","FLAGS"
;    4,-27.75, 152.45,-999,ADAM,0
;    5,-27.03, 152.02,-999,MARY,0
;    6,-26.76, 148.82,-999,DAVE,1
;    7,-26.58, 148.77,-999,RICK,0
;    8,-26.48, 148.68,1000,DENNIS,0
;    9,-26.30, 148.52, 900,TIM,0
;   10,-26.25, 148.41,-999,SPONGEBOB,0
;----------------------------------------------------------------------
begin
  csv_filename = "example3.csv"    ; name of CSV file to create
  dq = str_get_dq()                ; double quote character

;---Create dummy mixed data to write to CSV file
  fields = (/"ID",     "LAT",  "LON", "ELEV","SOURCE",             "FLAGS"/)
  ids    = (/   4,         5,      6,      7,       8,      9,          10/)
  lats   = (/-27.75,  -27.03, -26.76, -26.58,  -26.48, -26.30,      -26.25/)
  lons   = (/152.45, 152.02,  148.82, 148.77,  148.68, 148.52,      148.41/)
  elev   = (/-999,     -999,    -999,   -999,    1000,    900,        -999/)
  source = (/"ADAM", "MARY",  "DAVE", "RICK", "DENNIS", "TIM", "SPONGEBOB"/)
  flags  = (/     0,      0,       1,      0,         0,    0,           0/)

  
  fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated
                                                 ;   by commas.

  alist  = [/ids,lats,lons,elev,source,flags/]   ; List of variables to write.
  format = "%2d,%6.2f,%7.2f,%4d,%s,%1d"          ; Format to use for each variable.

;; Note: if you don't want spaces in CSV file, use the following format string.
;; format = "%d,%g,%g,%g,%s,%d"

  system("rm -rf " + csv_filename)               ; Remove file in case it exists.

  write_table(csv_filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(csv_filename, "a", alist, format)  ; Write mixed data to CSV file.


;---Echo the new file to the screen so you can see it.
  print("====== Contents of '" + csv_filename + "' ======")
  system("cat " + csv_filename)
  print("========================================")
end
