;*************************************************
; text_5.ncl
;
; Concepts illustrated:
;   - Adding a carriage return to a text string using a function code 
;   - Creating a main title
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","text")               ; send graphics to PNG file

  res                 = True                     ; plot mods desired
  res@tiMainString    = " A string with a carriage ~C~ return in it"
  plot=gsn_csm_xy(wks,u&lat,u,res)               ; create xy plot
end
