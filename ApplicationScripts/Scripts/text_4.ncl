;*************************************************
; text_4.ncl
;
; Concepts illustrated:
;   - Adding text to a plot using plot data coordinates
;   - Decreasing the font size of text
;   - Using "sprintf" to create nicely formatted text strings
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; open file and read in data
;************************************************
  in = addfile("h_avg_Y0191_D000.00.nc","r")
  t  = in->T
  lat=in->lat_t
  lon=in->lon_t
;************************************************
; create plot (this part is ce_3.ncl)
;************************************************
  wks = gsn_open_wks("png" ,"text")               ; send graphics to PNG file
  
  res                       = True                ; plot mods desired
  
  res@cnFillOn              = True                ; turn on color fill
  res@cnLinesOn             = False               ; turn off contour lines
  res@cnLevelSpacingF       = 0.5                 ; contour spacing
  res@cnFillPalette         = "BlAqGrYeOrRe"      ; set color map
  res@lbLabelStride         = 4                   ; every 4th label bar label
  res@gsnAddCyclic          = False               ; regional data
  res@mpMinLatF             = -60                 ; range to zoom in on
  res@mpMaxLatF             =  30.
  res@mpMinLonF             =  30.
  res@mpMaxLonF             = 120.
  
  res@gsnFrame              = False               ; don't advance frame yet
  res@gsnDraw               = False               ; don't draw plot yet

  plot = gsn_csm_contour_map_ce(wks,t(0,0,{-60:30},{30:120}), res)
;************************************************
; add text
;************************************************
  tres                      = True                ; text mods desired
  tres@txFontHeightF        = 0.015               ; make smaller
;
; Add some text that refers to actual values. This might be
; done to double check the plot with data values.
; 
  dum = new(18,graphic)
  do i=0,70,4
    dum(i/4) = gsn_add_text(wks,plot,sprintf("%3.1f", t(0,0,i,{89})),\
                            lon({89}),lat(i),tres)
  end do

  draw(plot)      ; Drawing the plot will draw all 18 text strings
  frame(wks)
end
