;*************************************************
; NCL Graphics: iso_2.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
;************************************************
; open netCDF file
;************************************************
  ocn_iso = addfile("iso_2040-2089_tw.nc","r")
;************************************************
; read in data
;************************************************
  iso    = ocn_iso->ISO                               ; read in iso field
;************************************************
;create monthly climatology from data
;clmMonLLT attaches attribute and coordinate variables
;************************************************
  monClm = clmMonLLT ( iso(lat_t|:,lon_t|:,time|:) )  ; in contributed
;************************************************
; common graphical parameters
;************************************************
  wks = gsn_open_wks("png","iso")                      ; send graphics to PNG file
  gsn_define_colormap(wks,"uniform")                   ; choose colormap

  rescn                = True
  rescn@cnFillOn       = True                  ; turn on color fill
  rescn@lbLabelBarOn   = False                 ; turn of label bar
  rescn@cnLineLabelsOn = True                  ; force line labels 
  rescn@cnInfoLabelOn  = False                 ; turn off cn info label
  rescn@cnLevelSelectionMode = "ManualLevels"  ; manual contour levels
;************************************************
; lat/lon pacific contour plot
;************************************************
; use dimension reduction to pass
  isoxy = iso({lat_t|-10:10},{lon_t|140:280},time|0) ; dimension info 
  isoxy = dim_avg(iso({lat_t|-10:10},{lon_t|140:280},time|:))/100.

  delete (isoxy@long_name)                     ; override below
  delete (isoxy@units)                         ; override below
  rescn@tiMainString    =  "Depth of 20C Isotherm (cm)" ;title
  rescn@tiXAxisString   =  "East Longitude"    ; x-axis title
  rescn@tiYAxisString   =  "North Latitude"    ; y-axis title

  rescn@vpWidthF        = .70          ; choose width of plot
  rescn@vpHeightF       = .30          ; choose height of plot

  rescn@cnMinLevelValF  =  30.         ; minimum contour level
  rescn@cnMaxLevelValF  = 160.         ; max contour level
  rescn@cnLevelSpacingF =  10.         ; contour spacing
  rescn@cnFillColors    = (/26,28,30,135,50,44,143,141,146,151,156,161,172/)

  rescn@tmYLMode   = "Explicit"                      ; explicitly label y axis
  rescn@tmYLValues = ispan(-10,10,1)             
  rescn@tmYLLabels = (/" "," ","-8.0"," ",""," ","-4.0"," "," ",\
                       " ", "0.0", " "," "," ","4.0"," "," "," " ,\
                       "8.0"," ", " "/)
  plt = gsn_csm_contour(wks,isoxy,rescn)                ; create plot
;*******************************************
; delete resources that will be changed
;*******************************************
  delete(rescn@tmYLValues)
  delete(rescn@tmYLLabels)
  delete(rescn@cnFillColors)
;*******************************************
; climatology year vs longitude plot
;*******************************************
  zplt = monClm(month|:,{lon_t|120:280},{lat_t|-2})  ; dim reduction
  zplt = dim_avg(monClm(month|:,{lon_t|120:280},{lat_t|-2:2}))/100.

  delete (zplt@long_name)
  delete (zplt@units)
  rescn@tiYAxisString   = "Months"                   ; y-axis title
  rescn@tiXAxisString   = "East Longitude"           ; x-axis title

  rescn@vpHeightF       = .5                         ; height of plot

  rescn@cnMinLevelValF  =  20.                       ; min contour level
  rescn@cnMaxLevelValF  = 170.                       ; max contour level
  rescn@cnLevelSpacingF =  10.                       ; contour interval
  rescn@cnFillColors    = (/26,27,28,30,135,50,44,143,141,146,151,\
                           156,161,172,173/)

  rescn@tmYLMode   = "Explicit"                        ; explicit labels
  rescn@tmYLValues = ispan(0,11,1)
  rescn@tmYLLabels = (/"J","F","M","A","M","J","J","A","S","O","N","D"/)

  plt = gsn_csm_contour(wks,zplt,rescn)
end
