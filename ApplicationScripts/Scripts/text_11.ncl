;*************************************************
; text_11.ncl
;
; Concepts illustrated:
;   - Attaching text strings to the outside of a plot
;   - Drawing titles on both Y axes
;   - Using "getvalues" to retrieve resource values
;   - Attaching annotations to plot
;   - Maximizing plots after they've been created
;   - Using functions for cleaner code
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

;*************************************************
;  Function to attach title to right Y axis
;*************************************************
function add_right_title(wks,plot,title)
local txres, font_height, txid, amres
begin
;---Retrieve font height of left axis string.
  getvalues plot
    "tiXAxisFontHeightF" : font_height
  end getvalues

;---Create a right axis text string to add to plot.
  txres               = True
  txres@txAngleF      = 90.          ; Rotate string clockwise 
  txres@txFontHeightF = font_height  ; Use same font height as left axis

  txid = gsn_create_text(wks, "Right Y axis string", txres)


;---Move text string to center/right edge of plot.
  amres                  = True
  amres@amParallelPosF   = 0.6    ; 0.5 is the right edge of the plot, so
                                  ; 0.6 is a little further to the right.
  amres@amOrthogonalPosF = 0.0    ; This is the center of the plot.
  amres@amJust           = "CenterCenter"

  annoid = gsn_add_annotation(plot, txid, amres)  ; Attach string to plot
  return(annoid)
end

;************************************************
; Main code
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","text")            ; send graphics to PNG file
  
  res              = True                     ; plot mods desired
  res@gsnDraw      = False                    ; Turn off draw and frame so
  res@gsnFrame     = False                    ; we can attach some text.

  res@tiYAxisString = "Left Y axis string"

  u = a->U(0,:,0)
  plot = gsn_csm_xy(wks,u&lat,u,res)               ; create xy plot

  amid = add_right_title(wks,plot,"Right Y axis string")
;
; Since we added string to outside of plot area, we need to 
; resize the plot so that it fits in the given workstation.
; This function draws the plot and advances the frame.
;
  psres = True                                                               
  psres@gsnPaperOrientation = "Portrait"
  maximize_output(wks,psres)
end
