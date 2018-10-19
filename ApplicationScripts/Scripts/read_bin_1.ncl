;----------------------------------------------------------------------
; read_bin_1.ncl
;
; Concepts illustrated:
;   - Using fbinrecread to read multiple variables off an unformatted binary file
;   - Adding meta data (attributes and coordinates) to a variable
;----------------------------------------------------------------------
begin
   lat  = fbinrecread ("./example.bin",0,  64, "double")
   lon  = fbinrecread ("./example.bin",1, 128, "double")
   t    = fbinrecread ("./example.bin",2, (/64,128/),"double")

;---Create lat and long coordinate variables
   lon!0          = "lon"
   lon@long_name  = "lon"
   lon@units      = "degrees-east"
   lon&lon        = lon

   lat!0          = "lat"
   lat@long_name  = "lat"
   lat@units      = "degrees_north"
   lat&lat        = lat

;---Name dimensions of t and assign coordinate variables
   t!0    = "lat"
   t!1    = "lon"
   t&lat  = lat
   t&lon  = lon
   t@long_name = "temperature"
   t@units     = "K"
end

