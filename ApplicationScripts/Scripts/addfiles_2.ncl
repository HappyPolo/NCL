;----------------------------------------------------------------------
; addfiles_2.ncl
;
; Concepts illustrated:
;   - Reading a variable off several NetCDF files using 'addfiles' and 'join' mode
;   - Calling 'ListSetType' to read variables in 'join' mode
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

;---Read "pottmp" in "join" mode and print a summary of the variable
   ListSetType (fall, "join") 

   pottmp = fall[:]->pottmp   ; note syntax [:]
   printVarSummary(pottmp)    ;  [ncl_join | 29] x [time | 12] x [level | 40] x [lat | 418] x [lon | 360]
end
