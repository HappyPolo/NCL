;----------------------------------------------------------------------
; write_asc_3.ncl
;
; Concepts illustrated:
;   - Writing formatted string, float, and integer data to an ASCII file
;----------------------------------------------------------------------
; This script uses "sprintf" and "sprinti", which can be much slower 
; than using "write_table". Use this script only for small ASCII files.
; See write_asc_2.ncl for how to use "write_table".
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;---Generate some dummy integer and float data.
   npts = 100
   i    = ispan(1,npts,1)
   j    = generate_unique_indices(npts)
   k    = generate_unique_indices(npts)
   x    = random_uniform(-10,10,npts)
   y    = random_uniform(0,1000.,npts)

   lines = "string_" + sprinti("%03i", j) + " " + \
           sprintf("%8.2f",x) +  " " + \
           sprinti("%4.0i", i) + " " + \
           sprintf("%8.1f",y) +  " " + \
           "    string_" + sprinti("%03i", k)

;---Write to a file
  asciiwrite("file3.txt",lines)
end
