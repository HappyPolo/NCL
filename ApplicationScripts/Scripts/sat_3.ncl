;================================================;
;  sat_3.ncl
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
;************************************************
; read in data 
;************************************************
  in = addfile("h_avg_Y0191_D000.00.nc","r")
  T=in->T
;************************************************
; create plot
;************************************************
  wks  = gsn_open_wks("png","sat")         ; send graphics to PNG file
  gsn_define_colormap(wks,"testcmap")      ; choose colormap

  res                       = True         ; plot mods desired
  res@cnFillOn              = True         ; turn on color
  res@cnLinesOn             = False        ; turn off contour lines
  res@cnLevelSpacingF       = 0.5          ; contour spacing
  res@cnFillDrawOrder       = "PreDraw"    ; fill first

  res@lbLabelStride         = 6            ; skip every other label
  res@lbBoxLinesOn          = False        ; turn off box between colors

  res@gsnSpreadColors       = True         ; use full colormap
  res@gsnSpreadColorStart   = 10           ; start at color 10
  res@gsnSpreadColorEnd     = 185          ; end at color 185
 
  res@mpProjection          = "Satellite"  ; choose map projection
  res@mpCenterLonF          = -35.         ; choose center lon
  res@mpCenterLatF          =  60.         ; choose center lat
  res@mpLimitMode           = "LatLon"     ; required
  res@mpMinLatF             =  30.         ; min lat
  res@mpMaxLatF             =  80.         ; max lat
  res@mpMinLonF             =  -80.        ; min lon
  res@mpMaxLonF             =  -10.        ; max lon

  res@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks
  res@mpGridAndLimbOn       = True         ; turn on lat/lon lines
  res@mpGridMaskMode        = "MaskLand"   ; Mask grid over land.
  res@gsnMaximize           = True         ; enlarge plot 
  res@tiMainString          = "Example of Zooming a Sat Projection"
  res@gsnAddCyclic          = False
  
  plot = gsn_csm_contour_map(wks,T(0,0,:,:),res)       

  end
