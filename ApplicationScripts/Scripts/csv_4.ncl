;***********************************************
; csv_4.ncl
;
; Concepts illustrated:
;   - Reading a CSV file
;   - Using str_get_field to parse a string
;   - Reading an ASCII file with delimiters
;
;***********************************************
;
; CSV file obtained from:
;   http://seepeoplesoftware.com/downloads/easytable-free/11-sample-csv-file-of-us-presidents.html
;
; This is example of parsing strings, and then further parsing
; those strings.
;
begin
  filename = "USPresident_Wikipedia_URLs_Thmbs_HW.csv"

;---Read in file as array of strings so we can parse each line.
  lines  = asciiread(filename,-1,"string")
  nlines = dimsizes(lines)-1   ; First line is a header

;
; Start reading in the fields we care about:
;
;    U.S. President name         (field 2)
;    Years in and out of office  (fields 4 and 5)
;    Home state                  (field 9)
;
; The first line is a header, so skip this.
;
  delim     = ","
  name     = str_get_field(lines(1:),2,delim)  
  date_in  = str_get_field(lines(1:),4,delim)  
  date_out = str_get_field(lines(1:),5,delim)  
  state    = str_get_field(lines(1:),9,delim)  

;---Parse year out of the date_in/date_out strings
  year_in  = str_get_field(date_in, 3,"/")
  year_out = str_get_field(date_out,3,"/")

;---Replace empty years with "????" to make it more clear.
  year_in  = where(year_in.eq."","????",year_in)
  year_out = where(year_out.eq."","????",year_out)

;---Print out the information
  npres = dimsizes(lines)-1   ; First line was a header
  do i=0,npres-1
    print("--------------------------------------------------")
    print(name(i) + ": in office " + year_in(i) + "-" + year_out(i))
    print("Home state: " + state(i))
  end do
  print("--------------------------------------------------")
end
