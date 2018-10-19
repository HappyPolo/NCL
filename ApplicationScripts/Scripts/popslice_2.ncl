;************************************
; popslice_2.ncl
;
; Concepts illustrated:
;   - Rearranging longitude data to span -180 to 180
;
; List not finished.
;
;************************************
; At southern latitudes these are true lon cross sections
; At northern latitudes these are not true
;    Must interpolate to lat/lon grid
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************
function reorder (xi[*][*]:numeric, zi[*], loni[*] ) 
; function to reorder longitudes and assign to variable 
begin
  ilon          = dimsizes(loni)
  loni@units    = "degrees_east"
; subscript where lon changes
  i             = ind(loni(1:ilon-1).lt.loni(0:ilon-2))
  ii            = ilon-i
  
  lono          = loni                      
  lono(0:ii-2)  = (/ loni(i+1:ilon-1) /)
  lono(ii-1:)   = (/ loni(0:i)        /)
; reorder variable
  xo   = xi     
  xo(:,0:ii-2)  = (/ xi(:,i+1:ilon-1) /) 
  xo(:,ii-1:)   = (/ xi(:,0:i)        /)
; assign coordinates
  xo&z_t        =  zi              ; assign with meters  
  xo!1          = "lon"
  xo&lon        =  lono     
; (optional) reorder data object (in contributed.ncl)
  xo = lonFlip( xo )               
  return (xo)
end
;************************************
begin
;************************************
; open pointer to file
;************************************ 
  pop    = addfile("CibmT31_gx3v4.pop.h.0001-06.nc","r")
;************************************
; manipulate vertical coordinate
;************************************ 
  z_t           = pop->z_t           ; read in
  z_t           = z_t*1.E-2          ; convert to m        
  z_t@long_name = "Depth (T grid)"   ; overwrite long name
  z_t@units     = "m"                ; change units attribute
;************************************
; read in data
;************************************ 
  nlts   = 11
  lon_t  = pop->TLONG(nlts,:)
  T_t    = pop->TEMP(0,:,nlts,:)   
  T      = reorder (T_t, z_t, lon_t ) ; create data object
  lat_t  = pop->TLAT(nlts,:)   ; read lats at each "nlts"
;************************************
; calculate labels
;************************************ 
  latavg = avg(lat_t) 
  latmin = min(lat_t)   
  latmax = max(lat_t)    
  if (latavg.gt.0.) then
    lat_label = sprintf("%0.1f", fabs(latavg))+"N"
  else
    lat_label = sprintf("%0.1f", fabs(latavg))+"S"
  end if
;************************************
; create plot
;************************************
  wks = gsn_open_wks("ps","popslice") 
  gsn_define_colormap(wks,"gui_default")  
  res                          = True       ; plot mods desired
  res@cnFillOn                 = True       ; turn on color fill
  res@cnLinesOn                = False      ; turn off contour lines
  res@cnLineLabelsOn           = False      ; turns off contour line labels
  res@cnInfoLabelOn            = False      ; turns off contour info label
  res@gsnSpreadColors          = True       ; use full colormap
  res@lbOrientation            = "vertical" ; vertical label bar
  res@trYReverse               = True       ; reverses y-axis  

; we are going to adjust the label bar after the plot is drawn, so we set
; these resources, so we will only see the final product.
  res@gsnFrame                 = False      ; don't advance frame yet
  res@gsnDraw                  = False      ; don't draw yet

  if (latmin.eq.latmax .and. latmin.eq.latavg) then
    res@tiMainString  = "cross-section: "+lat_label
  else
    res@tiMainString  = "cross-section (lat_ave): "+lat_label
  end if

; use lonPivot (in contributed.ncl) to reorder the longitudes so that no
; ocean basin is cut in half.  
  TT   = lonPivot(T,33.)
  plot = gsn_csm_contour(wks,TT,res)
;***************************************
;   adjust label bar
;***************************************
; Retrieve contour levels.
  getvalues plot
    "cnLevels" : levels
  end getvalues

  res@lbLabelStrings = sprintf("%3.1f",levels)   ; Format the labels
  plot               = gsn_csm_contour(wks,TT,res)
  draw(wks)
  frame(wks)
end

