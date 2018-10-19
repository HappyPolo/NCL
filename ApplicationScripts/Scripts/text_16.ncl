;*************************************************
; text_16.ncl
;
; Concepts illustrated:
;   - Aligning text strings by their decimal points
;   - Using "sprintf" to create nicely formatted text strings
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  model = (/ "MOD1",   "MOD2", "MOD3",  "MOD4", "MOD5"/)
  diff  = (/ 16.25,    -0.93,    0.43,     3.5,   0.0/)
  var   = (/  0.06,     0.02,    0.04,    0.05,  0.03/)
  ratio = (/     2,      2.4,     1.1,     0.9,   0.0/)
  ntext = dimsizes(model)

  wks = gsn_open_wks("png","text")    ; send graphics to PNG file

;----Create dummy blank plot to draw text strings on.
  res             = True
  res@gsnMaximize = True
  blank = gsn_csm_blank_plot(wks,res)

;---Create arrays to hold text objects.
  dum1  = new(ntext,graphic)
  dum2  = new(ntext,graphic)
  dum3  = new(ntext,graphic)
  dum4  = new(ntext,graphic)

;---Right-justify the model names
  txres               = True
  txres@txFontHeightF = 0.015
  txres@txJust        = "CenterLeft"
  xpos                = 0.60
  do i=0,ntext-1
    ypos = 0.25-i*0.05
    dum1(i) = gsn_add_text(wks,blank,model(i),xpos,ypos,txres)
  end do

;
; Use sprintf to make sure the floating point text strings have
; the same xxxx.yy format. Also, set the txJust resource to
; "CenterRight" so the strings line up by their decimal points.
;
  txres@txJust = "CenterRight"
  do i=0,ntext-1
    xpos = 0.75
    ypos = 0.25-i*0.05

    if(diff(i).ne.0.0) then
      str     = sprintf("%6.2f",diff(i))
      dum2(i) = gsn_add_text(wks,blank,str,xpos,ypos,txres)
    end if

    xpos = xpos + 0.08
    if(var(i).ne.0.0) then
      str     = sprintf("%5.2f",var(i))
      dum3(i) = gsn_add_text(wks,blank,str,xpos,ypos,txres)
    end if

    xpos = xpos + 0.08
    if(ratio(i).ne.0.0) then
      str     = sprintf("%4.1f",ratio(i))
      dum4(i) = gsn_add_text(wks,blank,str,xpos,ypos,txres)
    end if
  end do

  draw(blank)
  frame(wks)
end
