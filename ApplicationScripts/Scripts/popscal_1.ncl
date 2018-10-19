;================================================;
;  popscal_1.ncl
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  f         = addfile("TEMP.nc","r")

  t         = f->TEMP              ; (time, z_t, nlat, nlon) 
             
  t@lon2d   = f->TLONG             ; associate 2D arrays containing
  t@lat2d   = f->TLAT              ; coordinates with variable

;=================================================;
; Create plot [Black & White]
;=================================================;
  wks  = gsn_open_wks("png","popscal")              ; send graphics to PNG file
  res                     = True
  res@cnLineLabelDensityF = 4.0                     ; increase density of labels
  res@gsnAddCyclic        = True 
  plot = gsn_csm_contour_map(wks,t(0,0,:,:),res) ; time=0, z_t=0       
  end
