;================================================
;  mptick_8.ncl
;================================================
;
; Concepts illustrated:
;   - Drawing a cylindrical equidistant map
;   - Changing the tickmarks labels on a map
;   - Changing the font of a text string using a function code 
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

 wks  = gsn_open_wks("png","mptick")     ; send graphics to PNG file

  res              = True
  res@gsnMaximize  = True

  res@mpCenterLonF = 180

;
; The X axis labels will be aligned by the topmost characters, so
; they will look off. These two resources align them by the
; bottom character and add some space between the tickmarks
; and the labels.
;
  res@tmXBLabelJust   = "BottomCenter"
  res@tmXBLabelDeltaF = 1.0

;
; ~F33~ is the function code that gives us font table 33, which is 
; a set of greek characters. 
;
  res@tmXBMode   = "Explicit"
  res@tmXBValues = (/  0, 90, 180, 270, 360/)
  res@tmXBLabels = (/"0","~F33~p"+"/4", "~F33~p", "3"+"~F33~p"+"/4", \
                     "2"+"~F33~p"/)

  res@tmYLMode   = "Explicit"
  res@tmYLValues = (/ -90, 0, 90/)
  res@tmYLLabels = (/"-~F33~p"+"/2", "0", "~F33~p"+"/2"/)

  plot = gsn_csm_map(wks,res)        ; draw global map
end
