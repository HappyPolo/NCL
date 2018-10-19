;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************
begin
  filename = "archv.0021_016_00_3zu.nc"
  in       = addfile(filename,"r")
  u        = in->u
  lat      = in->Latitude
;*****************************************************
;   Create plot
;*****************************************************
 wks  = gsn_open_wks("ps","hycom")                  ; select output
 gsn_define_colormap(wks,"BlWhRe")                  ; choose colormap 

 res                             = True             ; plot mods desired

 res@cnFillOn                    = True             ; turn on color 
 res@cnLinesOn                   = False

;---This resource not needed in V6.1.0
 res@gsnSpreadColors             = True             ; use full color map

;---This resource defaults to True in NCL V6.1.0
 res@lbLabelAutoStride           = True             ; nice label bar labels

 res@cnLevelSelectionMode        = "ManualLevels"   ; manual contour levels
 res@cnMinLevelValF              = -0.2             ; set min contour level
 res@cnMaxLevelValF              =  0.2             ; set max contour level
 res@cnLevelSpacingF             =  0.05            ; contour interval

 res@trYReverse                  = True             ; reverse y axis
 res@tiMainString                = "Latitude: "+lat({30}) 

 plot  = gsn_csm_contour(wks,u(0,:,{30},:),res)

end




