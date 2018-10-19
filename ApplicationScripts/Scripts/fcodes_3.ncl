; ***********************************************
; fcodes_3.ncl
;
; Concepts illustrated:
;   - Adding a carriage return to a text string using a function code 
;   - Labeling the X axis with nicely-formatted time labels
;   - Generating dummy data using "random_uniform"
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  tstart = 2000
  tend   = 2006

  yyyymm   = yyyymm_time(tstart, tend, "integer")
  yyyyfrac = yyyymm_to_yyyyfrac(yyyymm,0)   ; create fractional years for 
                                            ; plotting purposes

  arr = random_uniform(-5.,10.,(tend-tstart+1)*12)  ; create random 1D array
     
  wks = gsn_open_wks("png","fcodes")  ; send graphics to PNG file
	
  res             = True

  res@vpWidthF    = 0.7      ; stretch the plot to be wider (in NDC units)
  res@vpHeightF   = 0.25     ; and not as tall.

  res@gsnMaximize = True     ; maximize plot in frame, aspect ratio preserved

  res@trXMinF     = tstart   ; starting point along X axis
  res@trXMaxF     = 2001

  res@tmXBMode    = "Explicit"  ; explicitly label X axis with custom labels.
  res@tmXBValues  = yyyyfrac(:12)    ; choose first 13 timesteps

;
; This example assumes you have a .hluresfile in your
; home directory that changes the default ":" function code
; to a "~":
;
;   *TextFuncCode  : ~             
;   *txFuncCode    : ~
;
  res@tmXBLabels  = (/" Jan ~C~2000"," Feb ~C~2000"," Mar ~C~2000", \
                      " Apr ~C~2000"," May ~C~2000"," Jun ~C~2000", \
                      " Jul ~C~2000"," Aug ~C~2000"," Sep ~C~2000", \
                      " Oct ~C~2000"," Nov ~C~2000"," Dec ~C~2000", \
                      " Jan ~C~2001"/)
				    
  res@tiMainString = "This is a main title~C~with a carriage return"

  plot = gsn_csm_xy(wks,yyyyfrac(:12),arr(:12),res)			    
end

	
	
