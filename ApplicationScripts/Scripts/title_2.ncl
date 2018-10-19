;----------------------------------------------------------------------
; title_2.ncl
;
; Concepts illustrated:
;   - Adding a carriage return to the main title using a function code 
;   - Shrinking the text in the middle of a main title
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read in netCDF file
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)

  wks = gsn_open_wks("png","title")                ; send graphics to PNG file

  res                 = True                       ; plot mods desired

; for this title effect, we use the function code "~" and the captical C to 
; indicate a carriage return in the string.  Additionally, the function code
; plus the capital Z indicates to resize the text. the 75 means 75% of
; normal. 

  res@tiMainString    = "This is the main title with a ~C~          carriage return~C~  and spaces for centering ~C~ ~Z75~         and font height changes"
                      
  plot=gsn_csm_xy(wks,u&lat,u,res)                 ; create xy plot

end
