;================================================;
;  mptick_6.ncl
;================================================;
;
; Concepts illustrated:
;   - Changing the tickmarks labels on a map
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  wks  = gsn_open_wks("png","mptick")   ; send graphics to PNG file

  res            = True
  res@tmXBMode   = "Explicit"                                                
  res@tmXBValues = (/-180, -90,    0,  90,   180/)                           
  res@tmXBLabels = (/"180","90W","EQ","90E","180"/)      
  plot = gsn_csm_map_ce(wks,res)        ; draw global map
end
