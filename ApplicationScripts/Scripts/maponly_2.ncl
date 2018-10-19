;----------------------------------------------------------------------
;  maponly_2.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Turning on map country boundaries
;   - Changing the color of map outlines
;   - Changing the thickness of map outlines
;   - Zooming in on a particular area on the map
;   - Turning off map fill
;   - Enabling the most up-to-date country boundaries
;----------------------------------------------------------------------
;
; Note: in NCL V6.4.0, mpDataBaseVersion will default to "MediumRes" 
; if mpOutlineBoundarySets and/or mpFillBoundarySets is set to 
; something other than "Geophyiscal".
;
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;----------------------------------------------------------------------
begin
  wks  = gsn_open_wks("png","maponly")           ; send graphics to PNG file


  res                             = True
  res@mpFillOn                    = False        ; turn off gray fill
  res@mpOutlineBoundarySets       = "National"   ; turn on country boundaries
  res@mpGeophysicalLineColor      = "Navy"       ; color of cont. outlines
  res@mpGeophysicalLineThicknessF = 1.5          ; thickness of outlines

  res@mpMaxLatF                   = 30           ; choose subregion           
  res@mpMinLatF                   = -50
  res@mpMaxLonF                   = 160
  res@mpMinLonF                   = 90
  plot = gsn_csm_map(wks,res)                 ; draw map

  res@mpMaxLatF                   = 90           ; choose a different subregion
  res@mpMinLatF                   = 10
  res@mpMaxLonF                   = 70
  res@mpMinLonF                   = 0

  plot = gsn_csm_map(wks,res)                 ; draw map

;
; The medium resolution map is required to get the most up-to-date
; country boundaries. The mpDataSetName resource only has an effect when
; mpDataBaseVersion is set to "MediumRes".
;
; In NCL V6.4.0, if mpOutlineBoundarySets is set to "National", then 
; this causes mpDataBaseVersion to automatically default to "MediumRes".
;
;  res@mpDataBaseVersion = "MediumRes"           ; choose higher resolution

;---This resource is still needed
  res@mpDataSetName = "Earth..4"                 ; choose most recent boundaries

  plot = gsn_csm_map(wks,res)                   ; draw map

  end
