;----------------------------------------------------------------------
;  mapoutlines_6.ncl
;----------------------------------------------------------------------
;
; Concepts illustrated:
;   - Illustrates NCL 6.4.0's new default behaviors for the 
;     mpDataBaseVersion resource:
;     - 1st map is completely default behavior, i.e., LowRes w/Geophysical
;       outlines
;     - 2nd map shows that MediumRes is used if mpFillBoundarySet
;       or mpOutlineBoundarySet is anything other than "Geophysical"
;     - 3rd map shows how LowRes can be requested regardless of
;       BoundarySet features.
;     - 4th map shows how MediumRes with just Geophysical features
;       can be requested (useful for highly zoomed in maps).
;     - 5th map shows explicit use of mpDataBaseVersion="Dynamic"
;
;----------------------------------------------------------------------
begin

  wks  = gsn_open_wks("png","mapoutlines") ; send graphics to PNG file

  res              = True
  res@gsnMaximize  = True
  res@mpFillOn     = False

  res@tiMainString = "NCL's default map database and Geophysical outlines"
  plot = gsn_csm_map(wks,res)

  res@tiMainString = "NCL's default map database and National outlines"
  res@mpOutlineBoundarySets = "National"
  plot = gsn_csm_map(wks,res)

  res@tiMainString      = "Explicitly invoked LowRes DB"
  res@mpDataBaseVersion = "LowRes"
  res@mpDataSetName     = "Earth..1"   ; 1 through 4
  plot = gsn_csm_map(wks,res)

  res@tiMainString      = "Explicitly invoked MediumRes DB w/Geophysical-only"
  res@mpDataBaseVersion = "MediumRes"
  res@mpOutlineBoundarySets = "Geophysical"
  res@mpDataSetName     = "Earth..1"   ; 1 through 4
  plot = gsn_csm_map(wks,res)

  res@mpDataBaseVersion = "Dynamic"
  res@mpOutlineBoundarySets = "Geophysical"
  res@tiMainString      = "Reset to Dynamic behavior"
  plot = gsn_csm_map(wks,res)
  
end
