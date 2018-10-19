;************************************
; POP_Graphics:  -- W. Wu 12/24/2003
; based on CSM_Graphics: slice_1.ncl
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************
begin
;************************************
; read in data
;************************************
  pop    = addfile("CibmT31_gx3v4.pop.h.0001-06.nc","r")
  
  ntm    = 0                  ; time subscript
  nlt    = 86                 ; latitude subscript
  
  lat    = pop->TLAT(nlt,:)    
  latavg = avg(lat)         
  
  lon_o  = pop->TLONG(nlt,:)
  nlon   = dimsizes (lon_o)
  
; Note: lon_o does not monotonously increase, so order change is necessary
  
  lon_t        = lon_o          ; trick to conserve meta data
  lon_t@units  = "degrees_east"
  
  lon_t( 0:38) = lon_o(61:99)
  lon_t(39:99) = lon_o( 0:60)

  ii           = ind(lon_t.GT. 180.0)
  lon_t(ii)    = lon_t(ii)-360. 

; Now lon_t is monotonously varying from 180W to 180E
  
  T_o          = pop->TEMP(ntm,:,nlt,:)   
  T = T_o 
; Note: order of T must change based on the order change of lon_t
; a better way to handle the order change is needed !!!!!!!
  
  T    (:,39:99) =   T_o(:, 0:60)
  T    (:, 0:38) =   T_o(:,61:99)
;************************************
; manipulate vertical coordinate
;************************************ 
  z_t           = pop->z_t
  z_t           = z_t*1.E-2       ; convert from cm to m
  z_t@long_name = "Depth (T grid)"; overwrite long name
  z_t@units     = "m"             ; fix units attribute
  
  T&z_t         = z_t             ; overwrite coord with modified z_t
  
  T!1    = "lon_t"                ; assign new coord info
  T&lon_t=  lon_t 
  T&z_t  =  z_t     
  
; use lonPivot (in contributed.ncl) to reorder the longitudes so that no
; ocean basin is cut in half.  
  T  = lonPivot(T, 33.)          
;************************************
; Create plot
;************************************
  wks = gsn_open_wks("ps" ,"popslice")   ; open a ps file
  gsn_define_colormap(wks,"gui_default") ; choose colormap
  
  res                      = True       ; plot mods desired
  res@cnFillOn             = True       ; turn on color fill
  res@cnLinesOn            = False      ; turn off contour lines
  res@cnLineLabelsOn       = False      ; turns off contour line labels
  res@cnInfoLabelOn        = False      ; turns off contour info label
  res@gsnSpreadColors      = True       ; use full colormap
  res@lbOrientation        = "vertical" ; vertical label bar
  res@trYReverse           = True       ; reverses y-axis
  
  res@tiMainString         = "cross-section (approx): "+sprintf("%5.1f", latavg)+"N"
  
  plot = gsn_csm_contour(wks,T,res)     ; create plot
end

