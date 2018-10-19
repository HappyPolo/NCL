;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************
begin
;************************************
 in1 = addfile("./T.pwc.01.2000.cdf","r")
 in2 = addfile("./U.pwc.01.2000.cdf","r")
 in3 = addfile("./V.pwc.01.2000.cdf","r")
 T=in1->Temp
 name = getfilevarnames(in2)
 U=in2->$name(0)$
 name = getfilevarnames(in3)
 V=in3->$name(0)$

 T&Longitude@units = "degrees_east"     ; required to match gsn_csm convention
 T&Latitude@units  = "degrees_north"    ; ditto

 U&Longitude@units = "degrees_east"     ; required to match gsn_csm convention
 U&Latitude@units  = "degrees_north"    ; ditto

 V&Longitude@units = "degrees_east"     ; required to match gsn_csm convention
 V&Latitude@units  = "degrees_north"    ; ditto
;************************************
; create plot
;************************************
 wks = gsn_open_wks("ps","pwc_5")            ; type and name of output
 gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose colormap


 res                      = True     ; plot mods desired

 res@cnFillOn             = True     ; turn on color fill
 res@cnLinesOn            = False    ; turn off contour lines
 res@gsnSpreadColors      = True     ; use full colormap
 res@gsnSpreadColorStart  = 14       ; start at color 14
 res@gsnSpreadColorEnd    = 193      ; end at color 193
 res@lbLabelStride        = 4        ; every 4th label bar label
 res@gsnScalarContour     = True     ; contours desired
 res@pmLabelBarOrthogonalPosF = 0.04 ; move label bar down

 res@tiMainString         = "20 Jan 2000"       ; main title
 res@gsnCenterString      = "Sigma Level: 0"    ; extra center string

;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
 i = NhlNewColor(wks,0.7,0.7,0.7)               ; add gray to colormap
 res@mpLandFillColor       = "gray"             ; change continent color 

 res@cnLevelSelectionMode = "ManualLevels"      ; manually set contour levels
 res@cnMinLevelValF       = 7.0                 ; just to make label bar
 res@cnMaxLevelValF       = 19.0                ; numbers come out even
 res@cnLevelSpacingF      = 0.25                ; contour spacing

 res@gsnAddCyclic         = False               ; regional data

 res@mpMaxLatF            = max(T&Latitude)     ; map subregion
 res@mpMinLatF            = min(T&Latitude)
 res@mpMaxLonF            = max(T&Longitude)
 res@mpMinLonF            = min(T&Longitude)

  res@vcGlyphStyle            = "CurlyVector"     ; turn on curley vectors
  res@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last

  res@vcRefMagnitudeF           = .2              ; define vector ref mag
  res@vcRefLengthF              = 0.045           ; define length of vec ref
  res@vcRefAnnoOrthogonalPosF   = -1.0            ; move ref vector

 plot=gsn_csm_vector_scalar_map_ce(wks,U(20,0,::4,::4),V(20,0,::4,::4),T(20,0,::4,::4),res)
end


