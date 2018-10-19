;================================================;
;  maponly_7.ncl
;================================================;
;
; Concepts illustrated:
;   - Masking out particular areas in a map
;
;=================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;=================================================;
begin

  wks  = gsn_open_wks("png","maponly")              ; send graphics to PNG file
  plot = gsn_csm_map_ce(wks,False)                  ; draw default
;****************************************************
; now remove small islands from map
;****************************************************
  res                           = True              ; plot mods desired
  res@mpAreaMaskingOn           = True              ; turn on area masking
  res@mpMaskAreaSpecifiers      = "SmallIslands"    ; don't draw this area
  res@mpOutlineOn               = False             ; turn off outline

  plot = gsn_csm_map_ce(wks,res)                    ; draw global map

  end
