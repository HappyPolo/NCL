;*************************************************
; text_12.ncl
;
; Concepts illustrated:
;   - Drawing three subtitles at the top of a plot
;   - Attaching text strings to the outside of a plot
;   - Attaching annotations to plot
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************

procedure subtitles(wks:graphic,plot:graphic,lstr:string,cstr:string, \
                    rstr:string,tres)
local txres, font_height, amres
begin
  if(tres) then
    txres = tres     ; Copy resources
  else
    txres = True
  end if
;
; Retrieve font height of left axis string and use to calculate size of
; subtitles.
;
  if(.not.isatt(txres,"txFontHeightF")) then
    getvalues plot
      "tiXAxisFontHeightF" : font_height
    end getvalues

    txres@txFontHeightF = font_height*0.9
  end if

;
; Set some some annotation resources.
;
  amres                  = True
  if(.not.isatt(txres,"amOrthogonalPosF")) then
    amres@amOrthogonalPosF = -0.53   ; Top of plot plus a little extra
                                     ; to stay out of the tickmarks.
  else
    amres@amOrthogonalPosF = txres@amOrthogonalPosF
  end if

;
; Create three strings to put at the top, using a slightly
; smaller font height than the axis titles.
;
  if(lstr.ne."") then
    txidl = gsn_create_text(wks, lstr, txres)

    amres@amJust           = "BottomLeft"
    amres@amParallelPosF   = -0.5   ; Left-justified
    annoidl = gsn_add_annotation(plot, txidl, amres)
  end if

  if(cstr.ne."") then
    txidc = gsn_create_text(wks, cstr, txres)

    amres@amJust           = "BottomCenter"
    amres@amParallelPosF   = 0.0   ; Centered
    annoidc = gsn_add_annotation(plot, txidc, amres)

  end if

  if(rstr.ne."") then
    txidr = gsn_create_text(wks, rstr, txres)

    amres@amJust           = "BottomRight"
    amres@amParallelPosF   = 0.5   ; Right-justifed
    annoidr = gsn_add_annotation(plot, txidr, amres)
  end if
end

begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","text")            ; send graphics to PNG file
  
  res              = True                     ; Plot mods desired.
  res@gsnMaximize  = True                     ; Maximize plot in frame.
  res@gsnDraw      = False                    ; Turn off draw and frame so
  res@gsnFrame     = False                    ; we can attach some text.

  res@tiMainString      = "This is the main title"
  res@tiMainFontColor   = "Brown"
  res@tiMainOffsetYF    = 0.02
  res@tiMainFontHeightF = 0.035

  plot = gsn_csm_xy(wks,u&lat,u,res)               ; Create xy plot.

  txres             = True                         ; Text resources desired
  txres@txFontColor = "ForestGreen"
  subtitles(wks,plot,"Left string","Center string","Right string",txres)

  draw(plot)     ; Drawing the plot will draw the three subtitles attached.
  frame(wks)
end
