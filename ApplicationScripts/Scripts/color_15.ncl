;*************************************************
; color_15.ncl
;
; Concepts illustrated:
;   - Using a blue-white-red color map
;   - Calculating symmetric contour intervals
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  in  = addfile("atmos.nc","r")
  u   = in->U(0,0,:,:)                            ; read in data
;************************************************
; create plot 1
;************************************************
  wks = gsn_open_wks("png","color")                ; send graphics to PNG file

  res                      = True                  ; plot mods desired
  res@cnFillOn             = True                  ; turn on color fill
  res@cnFillPalette        = "BlWhRe"              ; choose colormap

  res@cnLinesOn            = False

; automatically create nice min/max/ci values for blue/red colortable
  symMinMaxPlt (u,20,False,res)  
                  
  plot = gsn_csm_contour_map(wks,u, res)        ; create plot
  end
