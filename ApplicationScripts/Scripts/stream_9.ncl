;----------------------------------------------------------------------
; stream_9.ncl 
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Using opacity to emphasize or subdue overlain features
;   - Using stLevelPalette resource to assign a color palette
;----------------------------------------------------------------------
; This example will only work with NCL V6.1.0 or later.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Read in zonal winds
  dir   = ncargpath("data") + "/cdf/"
  u500f = addfile(dir + "U500storm.cdf","r")
  v500f = addfile(dir + "V500storm.cdf","r")
  u     = u500f->u
  v     = v500f->v

;---Fix the units
  u&lat@units = "degrees_north"
  u&lon@units = "degrees_east"

;---Start the graphics
  wks  = gsn_open_wks("png","stream")  ; send graphics to PNG file

  res                  = True
  res@gsnMaximize      = True          ; maximize in frame

  res@stLevelPalette   = "MPL_jet"     ; change the color palette
  res@stMonoLineColor  = False         ; color the streamlines
  res@stLineThicknessF = 2.0           ; twice as thick

  res@mpProjection     = "LambertEqualArea"

;---Zoom in on area that is roughly the United States.
  res@mpLimitMode      = "LatLon"
  res@mpMinLatF        =   18.
  res@mpMaxLatF        =   65.
  res@mpMinLonF        = -128.
  res@mpMaxLonF        =  -58.
  res@mpCenterLonF     = -100.0
  res@mpCenterLatF     =   40.0

  res@mpOutlineOn       = True
  res@mpLandFillColor   = "tan"
  res@mpOceanFillColor  = "skyblue"

  res@gsnAddCyclic      = False    ; Don't add cyclic longitude point

  res@tiMainString      = "Assigning color palette to streamlines"

  plot = gsn_csm_streamline_map(wks,u(0,:,:),v(0,:,:),res)

  res@stLineOpacityF    = 0.7   ; Make streamlines a little transparent
  res@tiMainString      = "Streamlines are partially transparent"

  plot = gsn_csm_streamline_map(wks,u(0,:,:),v(0,:,:),res)
end
