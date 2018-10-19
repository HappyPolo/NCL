;*****************************************************
; nlom_1.ncl
;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************
begin
;*****************************************************
; open file and read in data
;*****************************************************
  f1 = addfile("SSHTPMODGB12_HIN1993_19930415_IAS.nc","r")
  ssh = f1->SSHTPMODGB12_HIN1993__from_NLOM
  f2 = addfile("U1TPMODGB12_HIN1993_19930415_IAS.nc","r")
  u  = f2->U1TPMODGB12_HIN1993__from_NLOM
  f3 = addfile("V1TPMODGB12_HIN1993_19930415_IAS.nc","r")
  v  = f3->V1TPMODGB12_HIN1993__from_NLOM
  
  lat  = ssh&Latitude
  lon  = ssh&Longitude
;**************************************************
; assign required attributes
;**************************************************
  u&Longitude@units      = "degrees_east"
  v&Longitude@units      = "degrees_east"
  u&Latitude@units       = "degrees_north"
  v&Latitude@units       = "degrees_north"
  ssh&Longitude@units    = "degrees_east"
  ssh&Latitude@units     = "degrees_north"
;**************************************
;   Create plot
;***************************************
  wks  = gsn_open_wks("ps","nlom")                ; open ps file
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")       ; choose color map
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
  
  res@cnLevelSelectionMode        = "ManualLevels"; set manual contour levels
  res@cnMinLevelValF              = -40           ; set min contour level
  res@cnMaxLevelValF              =  40           ; set max contour level
  res@cnLevelSpacingF             =   5           ; contour interval
  
  res@cnMissingValFillColor       = "gray"        ; color missing values
  
  res@gsnScalarContour            = True          ; contours desired
  
  res@gsnSpreadColors             = True          ; use full color map
  res@gsnSpreadColorEnd           = -3            ; don't use added gray
  res@pmLabelBarOrthogonalPosF    = 0.06
  
  res@mpDataBaseVersion           = "MediumRes"    ; use finer database
  res@mpOutlineOn                 = True          ; turn on cont. outlines
  res@mpMaxLatF                   = max(lat)      ; zoom in
  res@mpMaxLonF                   = max(lon)
  res@mpMinLatF                   = min(lat)
  res@mpMinLonF                   = min(lon)
  
  res@vcGlyphStyle                = "CurlyVector" ; turn on curley vectors
  res@vcRefMagnitudeF             = 0.1           ; define vector ref mag
  res@vcRefLengthF                = 0.03          ; define length of vec ref
  res@vcRefAnnoOrthogonalPosF     = -1.0          ; move ref vector up/down
  res@vcRefAnnoParallelPosF       = 1.0           ; move left/right
  res@vcMinDistanceF              = 0.025         ; thin vectors
  res@vcRefAnnoString2            = u@units       ; unit string
  res@vcRefAnnoString2On          = True          ; turn on second string
  
  res@gsnLeftString               = ssh@long_name ; left string title
  res@gsnRightString              = ssh@units     ; right string title
  
  res@gsnMaximize                 = True          ; blow up plot
  
  
  plot = gsn_csm_vector_scalar_map_ce(wks, u,v,ssh,res)
end 



