;----------------------------------------------------------------------
; write_asc_5.ncl
;
; Concepts illustrated:
;   - Generating dummy data using random_normal
;   - Writing 2D arrays of data to an ASCII file using write_matrix
;----------------------------------------------------------------------
begin
  nrows = 5
  ncols = 7
  ave   = 0.0
  std   = 5.0
  xf    = random_normal (ave,std, (/nrows,ncols/))  ; float  
  xi    = round (xf, 3)                             ; integer
  xd    = todouble(xf)

  xf@_FillValue = 1e36
  xf(1,1) = xf@_FillValue
  xf(3,3) = xf@_FillValue

  option        = True
  option@row    = False
  option@tspace = 0

  option@fout   = "file5.f.txt"
  option@title  = "floating point data with two missing values"
  write_matrix (xf, "7f7.2", option)

  option@fout   = "file5.i.txt"
  option@title  = "integer data with no missing values"
  write_matrix (xi, "7i7", option)

  option@fout   = "file5.d.txt"
  option@title  = "double precision data with no missing values"
  write_matrix (xd, "7f7.2", option)
end

