; ===========================================
; hov_2.ncl
;
; Concepts illustrated:
;   - Creating a Hovmueller plot
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
; creat plot: Reverse time axis; contour labels horizontal
; Dash negative contours; double width of Zero
;============================================== 
 wks  = gsn_open_wks ("png", "hov")            ; send graphics to PNG file
 res                     = True                ; plot mods desired
 res@gsnContourZeroLineThicknessF = 2. 	       ; doubles thickness of zero contour
 res@gsnContourNegLineDashPattern = 1 	       ; sets negative contours to dash pattern 1
 res@trYReverse          = True                ; reverse y axis
 res@tiMainString        = "Reverse Time"      ; title
 res@cnLineLabelAngleF   = 0.0                 ; [cn] label horizontal

 plot  = gsn_csm_hov(wks, chi, res )           ; default hovmueller
end
