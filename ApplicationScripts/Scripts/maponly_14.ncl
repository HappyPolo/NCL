;================================================;
;  maponly_14.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing map outlines without lakes or islands
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  wks = gsn_open_wks("png","maponly")              ; send graphics to PNG file

;
; First show how to do this using the default map database.
;
  res                             = True              ; Plot mods desired

  res@mpFillOn                    = False
  res@mpOutlineSpecifiers         = (/"Continents", "Greenland"/)
  res@mpMaskOutlineSpecifiers     = (/ "InlandWater", "Islands" /)
  res@mpGeophysicalLineThicknessF = 3

  res@tiMainString = "Low res map database - simple continental outlines"
  plot = gsn_csm_map_ce(wks,res)

;
; Now show how to do this using the medium map database. This is a bit
; harder because many islands are "children" of continental entities
; such as "Canada". There is no way currently to specify "all children
; of Canada without Canada itself". Also there are children at the same
; level, such as islands, and children at the next level, provincial
; boundaries in Canada's case. The next frame draws all land forms
; without any inland water.
;
  delete(res@mpOutlineSpecifiers)
  delete(res@mpMaskOutlineSpecifiers)
  res@mpDataBaseVersion       = "MediumRes"
  res@mpOutlineSpecifiers     = "Ocean"
  res@mpMaskOutlineSpecifiers = "Water"    ; Gets rid of everything in the
                                           ; default geographic boundary set.
  res@tiMainString = "Medium res map database - simple continental outlines"
  plot = gsn_csm_map_ce(wks,res)

;
; There is no way to specify "islands" as a group, but there are some
; island groupings so here is what can be done without too much pain.
; For now, to get rid of islands like those that belong to Canada, each
; island would need to be specified individually -- a major pain .
;
  delete(res@mpMaskOutlineSpecifiers)
  res@mpMaskOutlineSpecifiers = (/"Water", "Atlantic Islands", \
                                  "Pacific Islands", "Indian Ocean Islands", \
                                  "Caribbean Islands"/)

  res@tiMainString = "Medium res map database - more simplified continental outlines"
  plot = gsn_csm_map_ce(wks,res)

end
