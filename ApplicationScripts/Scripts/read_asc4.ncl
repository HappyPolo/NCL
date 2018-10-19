load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; Read in the data as an array of strings.
  data   = asciiread("asc4.txt",-1,"string")
  nlines = dimsizes(data)

; First 3 lines and last 2 lines are header and
; footer stuff. Remove them.

  data2  = data(4:nlines-3)
  nlines = dimsizes(data2)       ; Recalculate # of lines

; Remove commas from strings.
  data_no_commas = str_sub_str(data2,",","")

;  print(data_no_commas)

; Write to a temporary file so we can read it back in as floating point.
  asciiwrite("tmp_file",data_no_commas)

;
; The temp data file contains 1 columns of alpha data and 2 columns
; of floating point data.  We only care about the 2 floating point
; columns here. The method below only works because the alpha
; column contains no numbers.
;
  ncols    = 2
  new_data = asciiread("tmp_file",(/nlines,ncols/),"float")

  print(new_data)

; No longer need temporary file.
  system("/bin/rm tmp_file")
end
