;----------------------------------------------------------------------
; write_bin_1.ncl
;
; Concepts illustrated:
;   - Using fbinrecwrite to write multiple variables to an unformatted binary file
;----------------------------------------------------------------------

begin 
;---read in a netCDF variable and output to binary
   fi   = addfile ("./01-11.nc", "r") 
   t    = fi->T                        ; read in netCDF variable

   file_out = "example.bin"            ; the "bin" extension is arbitrary
   system ("rm -f " + file_out)  ; remove any previously exist file

 ;************************************************************
 ; note the -1 indicates to just add on to the end of the file
 ; the (/.../) syntax means output the values only with no meta
 ; data
 ;************************************************************
   fbinrecwrite (file_out,-1, (/ fi->lat /))     
   fbinrecwrite (file_out,-1, (/ fi->lon /))
   fbinrecwrite (file_out,-1, (/ t(0,:,1,:) /))  ; output subsection 
end     
    
