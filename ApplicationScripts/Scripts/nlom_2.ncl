;*****************************************************
; nlom_2.ncl
;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
external SUBS "./composit.so"
;*****************************************************
begin
;*****************************************************
; open file and read in data
;*****************************************************
  f1 = addfile("SSTTPMODGB12_HIN1993_19930415_IAS.nc","r")
  tmp = f1->SSTTPMODGB12_HIN1993__from_NLOM
  lat  = tmp&Latitude
  lon  = tmp&Longitude
;*****************************************************
; mask out pacific with fortran subroutine composit
;*****************************************************
  sst = tmp
  SUBS::composit(tmp,lat,lon,dimsizes(lat),dimsizes(lon),tmp@_FillValue,sst)
;**************************************************
; assign required attributes
;**************************************************
  sst&Longitude@units    = "degrees_east"
  sst&Latitude@units     = "degrees_north"
;**************************************
;   Create plot
;***************************************
  wks  = gsn_open_wks("ps","nlom")                ; open ps file
  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose color map
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  i = NhlNewColor(wks,0.8,0.8,0.8)                ; add gray to colormap
  
  res                             = True          ; plot mods desired
  
  res@cnFillOn                    = True          ; turn on color 
  res@cnFillMode                  = "RasterFill"  ; raster mode (req for mem)
  res@cnLinesOn                   = False         ; no contour lines
  res@gsnAddCyclic                = False         ; regional data
  
  res@cnLevelSpacingF             =  0.2          ; contour interval
  
  res@cnMissingValFillColor       = "gray"
  
  res@gsnSpreadColors             = True          ; use full color map
  res@gsnSpreadColorEnd           = -3            ; don't use added gray
  res@pmLabelBarOrthogonalPosF    = 0.06          ; move label bar down
  res@lbLabelStride               = 4             ; label bar stride
  
  res@mpDataBaseVersion           = "MediumRes"    ; use finer database
  res@mpOutlineOn                 = True          ; turn on cont. outlines
  res@mpMaxLatF                   = max(lat)      ; zoom in
  res@mpMaxLonF                   = max(lon)
  res@mpMinLatF                   = min(lat)
  res@mpMinLonF                   = min(lon)
  
  res@gsnLeftString               = sst@long_name ; left string title
  res@gsnRightString              = sst@units     ; right string title
  res@gsnMaximize                 = True          ; blow up plot
  
  plot = gsn_csm_contour_map_ce(wks,sst,res)
end 



