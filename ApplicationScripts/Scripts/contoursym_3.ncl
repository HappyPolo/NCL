;----------------------------------------------------------------------
; contoursym_3.ncl
;
; Concepts illustrated:
;   - Using a green-yellow color map
;   - Calculating symmetric contour intervals
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;---Read in netCDF file
  in  = addfile("atmos.nc","r")
  u   = in->U(0,0,:,:)

  wks = gsn_open_wks("png","contoursym")           ; send graphics to PNG file

  res                      = True                  ; plot mods desired
  res@gsnMaximize          = True                  ; maximize plot in frame
  res@cnFillOn             = True                  ; turn on color fill
  res@cnFillPalette        = "GreenYellow"         ; set color map

  res@cnLinesOn            = False

;---Automatically create nice -X/X/spacing values for contour levels.
  symMinMaxPlt (u,20,False,res)  
                  
  plot = gsn_csm_contour_map_ce(wks,u, res)        ; create plot
end
