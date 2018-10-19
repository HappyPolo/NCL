;----------------------------------------------------------------------
; addfiles_1.ncl
;
; Concepts illustrated:
;   - Reading a variable off several NetCDF files using 'addfiles' and 'cat' mode
;----------------------------------------------------------------------
; The files read by this example are called pottmp.YYYY.nc, where
; 'YYYY' represents a four-digit year like '1980'.
;----------------------------------------------------------------------

begin
;---Get list of files from years 1980 to 2008
   yyyy      = ispan(1980,2008,1)
   all_files = "pottmp." + yyyy + ".nc"
  
;---Open files using addfiles
   fall = addfiles (all_files, "r")

;---Read "pottmp" in "cat" mode and print a summary of the variable
   pottmp = fall[:]->pottmp   ; note syntax [:]
   printVarSummary(pottmp)    ; [time | 348] x [level | 40] x [lat | 418] x [lon | 360]
end
