;***********************************************************
; csv_2.ncl
;
; Concepts illustrated:
;   - Reading a CSV file
;   - Using str_get_field to parse a string
;   - Using conversion functions to convert strings to numeric values
;   - Reading an ASCII file with delimiters
;
;***********************************************************
; This is an example of reading a CSV file that has string,
; integer, and float fields.
;***********************************************************

begin
  filename = "example2.csv"

;---Read in file as array of strings so we can parse each line
  lines = asciiread(filename,-1,"string")

  delim = ","

;---Read fields 1, 5 and 9.  The "var" suffix is used because "group" is a keyword.
  name_var  =           str_get_field(lines,1,delim)
  group_var = tointeger(str_get_field(lines,5,delim))
  size_var  =   tofloat(str_get_field(lines,9,delim))

;---Print the information
  print("Name is '" + name_var + "', group is " + group_var + ", size is " + size_var)
end