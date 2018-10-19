;----------------------------------------------------------------------
; write_csv_4.ncl
;
; Concepts illustrated:
;   - Writing a CSV file with a header using write_table
;   - Appending data of mixed types to a CSV file inside a loop
;----------------------------------------------------------------------
; This example is similar to write_csv_3.ncl, except it shows how
; to append data to a CSV file, rather than writing it all at once.
;
; This is useful, for example, if you are reading data from a file or
; a list of files inside a do loop and need to append data to the CSV
; as you go.
;
;----------------------------------------------------------------------
; Note: This example uses dummy data.
;
; The CSV file created by this script will look something like this:
;
;  "ID","NAME","LAT","LON","ELEV","SOURCE"
;  1,-31.7321,-63.2189,493.388,dummy_source_289
;  2,-26.4588,-124.574,566.211,dummy_source_820
;  3,-31.411,-57.5713,895.177,dummy_source_337
;  4,-38.6959,1.21715,773.531,dummy_source_22
;  5,-83.3376,-75.3851,86.0775,dummy_source_747
;  6,-25.2997,-105.074,79.7663,dummy_source_148
;  . . .
;
; If you use the "format" string with the formatted output, then
; the CSV file will look something like this:
;
;  "ID","NAME","LAT","LON","ELEV","SOURCE"
;   1, -31.73,  -63.22, 493.4, dummy_source_289
;   2, -26.46, -124.57, 566.2, dummy_source_820
;   3, -31.41,  -57.57, 895.2, dummy_source_337
;   4, -38.70,    1.22, 773.5, dummy_source_22
;   5, -83.34,  -75.39,  86.1, dummy_source_747
;   6, -25.30, -105.07,  79.8, dummy_source_148
;  . . .
;----------------------------------------------------------------------
begin
  csv_filename = "example4.csv"    ; name of CSV file to create
  dq = str_get_dq()                ; double quote character

;---Create dummy mixed data to write to CSV file
  fields = (/"ID","NAME","LAT","LON","ELEV","SOURCE"/)
  nvals  = 30
  ids    = ispan(1,nvals,1)
  
  fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated
                                                 ; by commas.
;;  format = "%d,%g,%g,%g,%s"

;; Note: if you want spaces in CSV file, use the following format string.
  format = "%3d,%7.2f,%8.2f,%6.1f, %s"           ; Format to use for each variable.

  system("rm -rf " + csv_filename)               ; Remove file in case it exists.

  write_table(csv_filename, "w", header, "%s")   ; Write header to CSV file.

;
; Loop through "nvals" and create dummy values to append
; a single single line of data to the the CSV file.
;
  do n=0,nvals-1
    lat    = random_uniform(-90,90,1)
    lon    = random_uniform(-180,180,1)
    elev   = random_uniform(0,1000,1)
    source = "dummy_source_" + toint(random_uniform(1,1000,1))

;---Put the values in a list, and append the mixed data to the CSV file
    alist  = [/ids(n),lat,lon,elev,source/]
    write_table(csv_filename, "a", alist, format)
  end do

;---Echo the new file to the screen so you can see it.
  print("====== Contents of '" + csv_filename + "' ======")
  system("cat " + csv_filename)
  print("========================================")
end
