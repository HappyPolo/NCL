;================================================
;  lb_5.ncl
;================================================
;
; Concepts illustrated:
;   - Customizing a labelbar for a contour plot
;   - Changing the orientation of the labelbar
;   - Turning off the perimeter around a labelbar
;   - Making the labelbar be horizontal
;   - Making the labelbar labels smaller
;   - Changing the stride of the labelbar labels
;   - Changing the width and height of a labelbar
;   - Changing the width and height of a plot
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
;=================================================;
; open file and read in data
;=================================================;
  f    = addfile("cone.nc","r")
  u  = f->u(4,:,:)                
;=================================================;
; PLOT 2
;=================================================;
  wks  = gsn_open_wks("png","lb")    ; send graphics to PNG file
  gsn_define_colormap(wks,"gui_default")

  res                     = True   ; plot mods desired
  res@cnFillOn            = True   ; turn on color
  res@gsnSpreadColors     = True   ; use full colormap
  res@gsnSpreadColorStart = 2      ; start with color 2
  res@gsnSpreadColorEnd   = -3     ; end with three before last
 
  res@vpWidthF  = 0.5              ; height and width of plot
  res@vpHeightF = 0.3

  res@cnInfoLabelOn = False        ; turn off contour info label

  res@lbAutoManage          = False             ; we control label bar
  res@pmLabelBarDisplayMode = "Always"          ; turns on label bar
  res@lbOrientation         = "Horizontal"      ; ncl default is vertical
  res@pmLabelBarSide        = "Bottom"          ; default is right
  res@lbLabelStride         = 2                 ; skip every other label
  res@pmLabelBarWidthF      = 0.4               ; default is shorter
  res@pmLabelBarHeightF     = 0.1               ; default is taller
  res@lbLabelFontHeightF    = .018              ; default is HUGE
  res@lbPerimOn             = False             ; default has box

  plot = gsn_contour(wks,u,res)                 ; contour the variable

; note above we used the generic interface to demonstrate all the
; resources that can be used to design a label bar. The gsn_csm_contour()
; interface would have created one automatically.

; In this file, the coordinate variables of the data are listed as 
; lat and long, but they are really just index points, which makes this
; data suitable for plotting without a map.

  end
