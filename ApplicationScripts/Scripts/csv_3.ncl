;***********************************************
; csv_3.ncl
;
; Concepts illustrated:
;   - Reading a CSV file
;   - Using str_get_field to parse a string
;   - Reading an ASCII file with delimiters
;   - Removing quotes from a string
;
;***********************************************
;
; This is an example of reading a CSV file (comma separated values)
; that has quotes around every field.
;
begin
  filename = "example3.csv"

;---Read in file as array of strings so we can parse each line
  lines  = asciiread(filename,-1,"string")
  nlines = dimsizes(lines)-1   ; First line is a header

;---This file has quotes around everything, which we don't want.
  dq    = str_get_dq()
  lines = str_sub_str(lines,dq,"")   ; Replace quotes with empty string

;---First line is name of each field
  delim       = ","
  field_names = str_split(lines(0),delim)
  nfields     = dimsizes(field_names)

;---We're going to read the whole file as a 2D array of strings
  fields = new((/nfields,nlines/),string)

;---Remember that fields start at 1, not 0.
  do nf=0,nfields-1
    fields(nf,:) = str_get_field(lines(1:),nf+1,delim)    
  end do

;---Print the information
  do nl=0,nlines-1
    print("======================")
    print("Line #" + (nl+1))
    do nf=0,nfields-1
      print(field_names(nf) + " is " + fields(nf,nl))
    end do
  end do
  print("======================")
end
