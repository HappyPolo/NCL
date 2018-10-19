;----------------------------------------------------------------------
; maponly_27.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Drawing four maps with four different land colors
;   - Changing the color of land
;   - Paneling four plots on a page.
;   - Turning off all tickmarks and labels
;   - Turning off borders of a map plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  wks  = gsn_open_wks("png","maponly")  ; send graphics to PNG file

;---One map will be drawn as four maps, with a lat/lon slice in the middle
  lon_slice = -100     
  lat_slice =   50
  delta_lat =   25
  delta_lon =   25
  min_lat   = lat_slice-delta_lat
  max_lat   = lat_slice+delta_lat
  min_lon   = lon_slice-delta_lon
  max_lon   = lon_slice+delta_lon

  
;---Set up common resources for all four maps
  res                   = True

  res@gsnMaximize       = True 
  res@gsnDraw           = False   ; Will panel later
  res@gsnFrame          = False

  res@mpDataBaseVersion  = "MediumRes"
  res@tmBorderThicknessF = 4.       ; 4x thicker
 
;---Turn off all tickmarks and labels
  res@tmXBOn            = False
  res@tmYLOn            = False
  res@tmXTOn            = False
  res@tmYROn            = False
;
; Start setting resources for individual maps
;
; Lower left quadrant
;
  res@mpMinLatF         = min_lat
  res@mpMaxLatF         = lat_slice
  res@mpMinLonF         = min_lon
  res@mpMaxLonF         = lon_slice
  res@mpLandFillColor   = "green"

  res@tmXBBorderOn      = False
  res@tmXTBorderOn      = True
  res@tmYLBorderOn      = False
  res@tmYRBorderOn      = True

  ll_map = gsn_csm_map_ce(wks,res)

;---Lower right quadrant
  res@mpMinLatF         = min_lat
  res@mpMaxLatF         = lat_slice
  res@mpMinLonF         = lon_slice
  res@mpMaxLonF         = max_lon
  res@mpLandFillColor   = "salmon"

  res@tmXBBorderOn      = False
  res@tmXTBorderOn      = True
  res@tmYLBorderOn      = True
  res@tmYRBorderOn      = False

  lr_map = gsn_csm_map_ce(wks,res)

;---Upper left quadrant
  res@mpMinLatF         = lat_slice
  res@mpMaxLatF         = max_lat
  res@mpMinLonF         = min_lon
  res@mpMaxLonF         = lon_slice
  res@mpLandFillColor   = "orange"

  res@tmXBBorderOn      = True
  res@tmXTBorderOn      = False
  res@tmYLBorderOn      = False
  res@tmYRBorderOn      = True

  ul_map = gsn_csm_map_ce(wks,res)

;---Upper right quadrant
  res@mpMinLatF         = lat_slice
  res@mpMaxLatF         = max_lat
  res@mpMinLonF         = lon_slice
  res@mpMaxLonF         = max_lon
  res@mpLandFillColor   = "cyan4"

  res@tmXBBorderOn      = True
  res@tmXTBorderOn      = False
  res@tmYLBorderOn      = True
  res@tmYRBorderOn      = False

  ur_map = gsn_csm_map_ce(wks,res)

;---Panel all four plots
  pres             = True
  pres@gsnMaximize = True

  gsn_panel(wks,(/ul_map,ur_map,ll_map,lr_map/),(/2,2/),pres)
end
