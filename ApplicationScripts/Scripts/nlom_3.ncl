;*****************************************************
; nlom_1.ncl
;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************
begin
;*****************************************************
; combine individual layer files into one variable 
;*****************************************************
  pv = new((/5,417,501/),"float")
  do i = 1, 5
     in = addfile("PV"+i+"TPMODGB12_HIN1993_19930415_IAS.nc","r")
     var = "PV"+i+"TPMODGB12_HIN1993__from_NLOM"
     pv(i-1,:,:)= in->$var$
  end do 
;*****************************************************
; b/c we had to create this 3D variable from scratch, we
; have to manually assign all the meta data.      
;*****************************************************      
  lat       = in->Latitude                    ; read in lat/lon arrays
  lon       = in->Longitude
  lon@units = "degrees_east"                  ; add missing attribute
  lat@units = "degrees_north"
  
  pv!0 = "layer"                              ; name dimensions
  pv!1 = "lat"
  pv!2 = "lon"
  pv&lat =lat                                 ; assign coordinate variables.
  pv&lon =lon
;**************************************
;   Create plot
;***************************************
  wks  = gsn_open_wks("ps","nlom")            ; open ps file
  gsn_define_colormap(wks,"gui_default")       ; choose colormap
  res                      = True
  
  res@cnFillOn             = True              ; turn on color fill
  res@cnLineLabelsOn       = False             ; turns off contour line labels
  res@cnInfoLabelOn        = False             ; turns off contour info label
  res@gsnSpreadColors      = True              ; use full colormap
  res@lbLabelStride        = 4                 ; label bar stride
  res@trYReverse           = True              ; reverses y-axis
  res@cnLinesOn            = False             ; turn off contour lines
  
  res@vpWidthF             = 0.8               ; stretch the plot aspect
  res@vpHeightF            = 0.6
  res@vpXF                 = 0.15
  res@vpYF                 = 0.85
  
; titles  
  res@gsnLeftString        = "potential vorticity"
  res@gsnRightString       = pv@units     
  res@tiMainString         = "Slice along 64W"
  res@tiYAxisString        = "Layer"
  
; selected here is the first two levels using standard subscripting,
; latitude 12 through 20 using coorindate subscripting ( the {} ) and
; longitude 296 which corresponds to 64W.  
  plot = gsn_csm_contour(wks,pv(0:2,{12:20},{296}),res)     ; create plot

end 



