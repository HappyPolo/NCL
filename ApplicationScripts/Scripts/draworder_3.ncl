;*************************************************
; draworder_3.ncl
;
; Concepts illustrated:
;   - Using draw order resources to draw map grid lines under land
;   - Using draw order resources to draw contour labels under land
;   - Drawing a satellite map
;   - Changing the view of a satellite map
;   - Changing the land fill color
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  cdf_file = addfile("slp.1963.nc","r") 
;************************************************
; read in data 
;************************************************
  slp    = cdf_file->slp(:,::-1,:)              
  newslp = ((slp*slp@scale_factor)+slp@add_offset)*.01  
  copy_VarCoords(slp,newslp)

;************************************************
; plotting parameters
;************************************************
  wks = gsn_open_wks("png","draworder") ; send graphics to PNG file
  colors = (/"white","black","sandybrown"/)

  res                           = True       ; plot mods desired

  res@gsnMaximize               = True       ; maximize plot

  res@mpLandFillColor           = "Sandybrown"

  res@mpProjection              = "Satellite" ; choose map projection
  res@mpCenterLatF              = 20.         ; choose center lat

  res@mpOutlineOn               = True        ; turn on continental outlines
  res@mpGridAndLimbOn           = True
  res@mpGridLineDashPattern     = 2

  res@cnLevelSelectionMode 	= "ManualLevels"  ; manually set cont levels
  res@cnMinLevelValF       	= 948             ; min lev
  res@cnMaxLevelValF	        = 1064            ; max lev
  res@cnLevelSpacingF           = 4               ; spacing
  res@cnFillPalette             = colors          ; set color map

  res@tiMainString    = "Labels, grid lines on top of land"

  map = gsn_csm_contour_map(wks,newslp(24,:,:),res)

  res@tiMainString    = "Labels, grid lines under land"

  res@mpGridAndLimbDrawOrder    = "PreDraw"
  res@cnLabelDrawOrder          = "PreDraw"
  map = gsn_csm_contour_map(wks,newslp(24,:,:),res)
  	
end
	 
