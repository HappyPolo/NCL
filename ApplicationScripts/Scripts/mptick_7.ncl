;================================================;
;  mptick_7.ncl
;================================================;
;
; Concepts illustrated:
;   - Changing the tickmarks labels on a map
;   - Creating map tickmark labels with degree symbols
;   - Drawing superscripts/subscripts in a text string using function codes 
;   - Forcing tickmarks and labels to be drawn on the top X axis in a map plot
;   - Forcing tickmarks and labels to be drawn on the right Y axis in a map plot
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  wks  = gsn_open_wks("png","mptick")     ; send graphics to PNG file

  res            = True
;
; Put labels with the degree symbol on the X and Y axes.
;
  res@tmXBMode   = "Explicit"
  res@tmXBValues = ispan(-180,180,60)
  res@tmXBLabels = (/"180", "120~S~o~N~W","60~S~o~N~W","0", \
                     "60~S~o~N~E", "120~S~o~N~E","180"/)

  res@tmYLMode   = "Explicit"
  res@tmYLValues = ispan(-90,90,45)
  res@tmYLLabels = (/"90~S~o~N~S","45~S~o~N~S","0",\
                     "45~S~o~N~N","90~S~o~N~N"/)

  plot = gsn_csm_map_ce(wks,res)        ; Draw global map.

  res@tmXTLabelsOn = True               ; Turn on labels for top and right
  res@tmYRLabelsOn = True               ; axes. They are off by default.

  plot = gsn_csm_map_ce(wks,res)        ; Draw global map.
end
