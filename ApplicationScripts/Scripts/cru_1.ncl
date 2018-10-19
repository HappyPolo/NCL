;*****************************************************
; cru_1.ncl
;
; Concepts illustrated:
;   - Plotting CRU (Climate Research Unit) data
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Turning off contour lines
;   - Turning off contour line labels
;   - Converting "short" data to "float"
;   - Spanning the full color map for contour fill
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
;*****************************************************
begin
;*****************************************************
; Read Absolute temperatures for the base period 1961-90
; data are stored as type "short" ... convert to float
;***************************************************
  f    = addfile("absolute.nc","r")
  T    = short2flt( f->tem )                          ; contributed.ncl
  T@long_name = "Temperature"          ; change value original too long
;***************************************
; create individual plots
;***************************************  
  wks = gsn_open_wks("png","cru")               ; send graphics to PNG file
  
  res                      = True               ; plot mods desired

  res@cnFillOn             = True               ; color contours
  res@cnFillPalette        = "BlAqGrYeOrReVi200"      ; set color map
  res@cnLinesOn            = False              ; default is True
  res@cnLineLabelsOn       = False              ; default is True

  plot  = gsn_csm_contour_map(wks,T(0,:,:),res)
end
