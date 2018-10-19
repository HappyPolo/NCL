;================================================;
;  maponly_8.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing continent outlines only
;   - Turning off map fill
;   - Turning on map outlines
;   - Drawing states/provinces of a country
;
;=================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;=================================================;
begin

  wks  = gsn_open_wks("png","maponly")              ; send graphics to PNG file

  res                           = True              ; plot mods desired
  res@mpOutlineOn               = True              ; turn off outline
  res@mpFillOn                  = False             ; turn off map fill

  plot = gsn_csm_map(wks,res)                   ; draw map

; Tell the map to outline nothing except what is specified in 
; mpOutlineSpecifiers                                                
  res@mpOutlineBoundarySets     = "NoBoundaries"     
  res@mpOutlineSpecifiers      = (/"Continents"/)  ; continents only

  plot = gsn_csm_map(wks,res)                    ; draw global map
	
  res@mpDataSetName         = "Earth..4"   ; This database contains
                                           ; divisions for other countries.
  res@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database
  res@mpMinLatF = 0.
  res@mpMaxLatF = 55.
  res@mpMinLonF = 60.
  res@mpMaxLonF = 140.
	
  res@mpGeophysicalLineThicknessF= 2.      ; double the thickness of geophysical boundaries
  res@mpNationalLineThicknessF= 2.         ; double the thickness of national boundaries
  delete(res@mpOutlineSpecifiers)          ; about to change size of attribute, must delete
  res@mpOutlineSpecifiers = (/"China:states","India","Nepal","Bhutan","Bangladesh","Myanmar", \
	                            "Thailand","Cambodia","Vietnam","Taiwan"/)
  plot = gsn_csm_map(wks,res)                    ; draw global map
end
