begin
 wks   = gsn_open_wks ("png","blank")                  ; send graphics to PNG file

 res                   = True                       ; plot mods desired
 res@gsnMaximize       = True
 res@tiMainString      = "Blank plot"
 plot  = gsn_csm_blank_plot (wks,res)
 draw(plot)
 frame(wks)

end
