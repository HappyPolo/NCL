; ===========================================
; hov_6.ncl
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;=============================================
; data processing
;=============================================
  diri  = ncargpath("data") + "/cdf/"
  f     = addfile (diri+"chi200_ud_smooth.nc","r")
  scale = 1.e6                                  ; scale factor
  chi   = f->CHI                                ; get chi
  chi   = chi/scale                             ; scale for convenience
;==============================================
; create plot
;============================================== 
  wks  = gsn_open_wks ("png", "hov" )           ; send graphics to PNG file
  
  res                     = True                ; plot mods desired
  res@tiMainString        = "90 deg Spacing"    ; title
  res@gsnMajorLonSpacing  = 90.
  
  plot = gsn_csm_hov(wks, chi, res )            ; draw plot
end

