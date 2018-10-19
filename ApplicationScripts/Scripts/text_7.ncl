;*************************************************
; text_7.ncl
;
; Concepts illustrated:
;   - Drawing superscripts/subscripts in a text string using function codes
;   - Drawing degree symbols in tickmark labels
;   - Explicitly setting tickmarks and labels on the bottom X axis
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","text")            ; send graphics to PNG file
  
  res              = True                     ; plot mods desired

  res@tiMainString = "Adding a degree symbol to a text string"

  res@tmXBMode     = "Explicit"                ; explicit lables 
  res@tmXBValues   = (/-90,-60,-30,0,30,60,90/); where located
; to put a degree symbol in a string, we use the function code "~" to 
; superscript a "o" into the text. Note that the function code is a "~" 
; in this example because we have changed the default function code of a 
;  ":" in our .hluresfile to be a "~". The "~S~ indicates a superscript, 
; and the "~N~" indicates back to normal space.
  res@tmXBLabels   = (/"90~S~o~N~","60~S~o~N~","30~S~o~N~","0","30~S~o~N~",\
  "60~S~o~N~","90~S~o~N~"/)  

  plot=gsn_csm_xy(wks,u&lat,u,res)               ; create xy plot

end
