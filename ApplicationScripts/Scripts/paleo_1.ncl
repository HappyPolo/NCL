;************************************
; CSM_Graphics: paleo_1.ncl
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
;************************************
begin
;************************************
  in = addfile("h_avg_Y0050_D000.00.nc","r")
  T=in->T(0,0,:,{0:360})              ; get rid of cyclic points
  lat_t=in->lat_t                     ; read in lat and lon
  lon_t=in->lon_t({0:360})
;************************************
  wks = gsn_open_wks("ps","paleo")    ; open a ps file
  gsn_define_colormap(wks,"gui_default")   ; choose colormap
  
  res                      = True     ; plot mods desired
  res@cnFillOn             = True     ; turn on color fill
  res@mpOutlineOn          = False    ; turn off continental outline
  res@mpCenterLonF         = 180      ; center longitude at 180
  res@gsnSpreadColors      = True     ; use full range of colors
  res@mpFillOn             = False    ; turn off modern continents

  plot = gsn_csm_contour_map_ce(wks,T,res)     ; create plot
 
end


