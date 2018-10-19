; ===========================================
; hov_1.ncl
;
; Concepts illustrated:
;   - Creating a Hovmueller plot
;   - Using text function codes to generate umlauts
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
 fili  = "chi200_ud_smooth.nc"                 ; filename
 
 f     = addfile (diri+fili , "r")             ; add file
 scale = 1.e6                                  ; scale factor
 chi   = f->CHI                                ; get chi
 chi   = chi/scale                             ; scale for convenience
;==============================================
; creat plot
;============================================== 
 wks  = gsn_open_wks ("png", "hov" )           ; send graphics to PNG file
 uuml    = "u~H-13V2F35~H~FV-2H3~"             ; This creates a U with umlauts
 res              = True                       ; plot mods desired
 res@tiMainString = "Default Hovm"+ uuml + "ller"       ; title
 plot = gsn_csm_hov(wks, chi, res )            ; default hovmueller
end
