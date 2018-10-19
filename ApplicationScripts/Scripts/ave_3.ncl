;**************************************
;  ave_3.ncl
;
; Concepts illustrated:
;   - Calculating a volume weighted average
;
;**************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************
begin
;****************************************
  in = addfile("atmos.nc","r")
  t  = in->T                             ; read in data
  gw = in->gw                            ; get gaussian weights for ave
;****************************************
; calculate volume averages
;****************************************
; arguments:
; data
; weights in z direction
; weights in y direction
; weights in x direction (we just use 1.0 since there are none)
; option (0 means use missing values, 1 means the ave will be missing if
;    ANY data in the array is missing.

  hya = in->hyai
  hyb = in->hybi
  p0   = in->P0
  ps   = in->PS
  dp   = dpres_hybrid_ccm(ps,p0,hya,hyb)
  globvol = wgt_volave_ccm(t,dp,gw,1.0,0)
;****************************************
; Create plot
;****************************************
 wks = gsn_open_wks("png","ave")      ; send graphics to PNG file
 res = True
 res@gsnCenterString = "Global volume ave: " + globvol
 plot = gsn_csm_contour_map(wks,t(0,0,:,:),res); create plot
end


