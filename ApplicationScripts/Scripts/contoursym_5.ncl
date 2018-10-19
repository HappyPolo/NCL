;----------------------------------------------------------------------
; contoursym_4.ncl
;
; Concepts illustrated:
;   - Using a symmetric color map
;   - Using a blue-red color map
;   - Explicitly setting contour levels
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
;---Read in netCDF file
  in  = addfile("atmos.nc","r")
  u   = in->U(0,0,:,:)

;---Start the graphics
  wks = gsn_open_wks("x11","contoursym")        ; send graphics to PNG file


  res                      = True

  res@gsnMaximize          = True               ; maximize plot in frame

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -31
  res@cnMaxLevelValF       =  31
  res@cnLevelSpacingF      =   2

  res@cnFillOn             = True               ; turn on contour fill
  res@cnFillPalette        = "BlWhRe" 
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour labels


  plot = gsn_csm_contour_map(wks,u,res)
  getvalues plot@contour
    "cnLevels" : levels
  end getvalues
print(levels)

end
