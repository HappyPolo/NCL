load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;********************************************
begin                                                                        
; 1. means one row of type float
  head  = readAsciiHead ("nodc_1.flat", 1.)
; separate out parts of header into individual variables
  date  = floattointeger(head(0))                                             
  lat   = head(1)                                                             
  lon   = head(2)                                                             
 
; 3 is number of columns, 1 is number of lines in header to skip
  data  = readAsciiTable("nodc_1.flat", 3, "float", 1)

; separate out depth
  depth           = data(:,0)
  depth@long_name = "depth"
  depth@units     = "m"

; separate out temperature
  temp           = data(:,1)
  temp@long_name = "temperature"
  temp@units     = "degC"

; separate out salinity
  sal           = data(:,2)
  sal@long_name = "salinity"
  sal@units     = "ppm" 
;**************************
; create plot
;**************************                                    
  wks   = gsn_open_wks ("ps","modasP")               ; open workstation

  res                   = True                       ; plot mods desired 
  res@gsnCenterString   = date                       ; add center string
  res@tiMainString      = lat +"N "+lon              ; add title
  res@trYReverse        = True                       ; reverse Y-axis
  plot  = gsn_csm_xy (wks,temp,depth,res)            ; create plot

  plot  = gsn_csm_xy (wks,sal,depth,res)             ; create plot
  
                                    
end   
                     
