;----------------------------------------------------------------------
; write_asc_1.ncl
;
; Concepts illustrated:
;   - Writing an array of data to an ASCII file using asciiwrite
;----------------------------------------------------------------------
  data = random_uniform(-5,5,(/2,3,4/))   ; Generate a dummy 2 x3 x 4 array
  asciiwrite("file1.txt",data)            ; Write it to a file
