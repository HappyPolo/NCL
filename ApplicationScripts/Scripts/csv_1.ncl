;***********************************************************
; csv_1.ncl
;
; Concepts illustrated:
;   - Reading a CSV file using two different methods
;   - Using asciiread to read an ASCII file with delimiters
;   - Using str_split_csv to read an ASCII file with delimiters
;   - Reshaping a one-dimensional array
;***********************************************************

begin
  filename = "example1.csv"

;----------------------------------------------------------------------
; This method uses "asciicread" to read the data
;----------------------------------------------------------------------

;---Read the values in as 1D array of strings to get rows and columns.
  values_1d = asciiread(filename,-1,"string")
  ncols     = dimsizes(str_split(values_1d(0),","))
  nrows     = dimsizes(values_1d)

  print("This file has " + nrows + " rows and " + ncols + " columns.")

;---Reread values as integers and reshape at the same time.
  values_2d = onedtond(asciiread(filename,-1,"integer"),(/nrows,ncols/))

  opt = True
  opt@title = "Using asciiread and onedtond"
  write_matrix(values_2d,ncols+"I5",opt)

;----------------------------------------------------------------------
; This method uses "str_split_csv" to read the data. You still have
; to use asciiread to first read the data as an array of strings.
;----------------------------------------------------------------------
  str_array = asciiread(filename,-1,"string")
  values_2d = toint(str_split_csv(str_array,",",0))

  opt@title = "Using asciiread and str_split_csv"
  write_matrix(values_2d,ncols+"I5",opt)
end
