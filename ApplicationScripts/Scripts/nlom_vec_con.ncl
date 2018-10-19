;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************
begin
;*****************************************************
; User's parameters
;*****************************************************
colormap   = "BlGrYeOrReVi200"
mincn      = 10         ; min contour
maxcn      = 50        ; max contour
cnint      = 2         ; contour interval

;mincn      = 0.         ; min contour
;maxcn      = .5        ; max contour
;cnint      = .05        ; contour interval

refvec     = .1        ; value of reference vector
linesOn    = False      ; turn on contour lines
output     = "ps"      ; can be "ps","eps","epsi","x11",or "ncgm"
;*****************************************************
; NO USERS CHANGES AFTER THIS POINT
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
    u&Longitude@units    = "degrees_east"
    v&Longitude@units    = "degrees_east"
    u&Latitude@units     = "degrees_north"
    v&Latitude@units     = "degrees_north"
    ssh&Longitude@units    = "degrees_east"
    ssh&Latitude@units     = "degrees_north"
;**************************************
;   Create plot
;***************************************
 wks  = gsn_open_wks(output,"ias_plot")
 gsn_define_colormap(wks,colormap)             ; choose color map
 i = NhlNewColor(wks,0.7,0.7,0.7)              ; add gray to colormap

 res                             = True             ; plot mods desired

 res@cnFillOn                    = True             ; turn on color 
 res@cnFillMode                  = "RasterFill"     ; turn on raster mode (required for memory)
 res@cnLinesOn                   = linesOn          ; no contour lines
 res@gsnAddCyclic                = False            ; regional data

; res@cnLevelSelectionMode        = "ManualLevels"   ; set manual contour levels
; res@cnMinLevelValF              = mincn            ; set min contour level
; res@cnMaxLevelValF              = maxcn            ; set max contour level
; res@cnLevelSpacingF             = cnint            ; contour interval


 res@gsnScalarContour            = True             ; contours desired

 res@gsnSpreadColors             = True             ; use full color map
 res@gsnSpreadColorEnd           = -3               ; don't use added gray
 res@lbOrientation               ="vertical"        ; vertical label bar

 res@mpDataBaseVersion           = "MediumRes"       ; use finer database
 res@mpOutlineOn                 = True             ; turn on cont. outlines
 res@mpMaxLatF                   = max(lat)
 res@mpMaxLonF                   = max(lon)
 res@mpMinLatF                   = min(lat)
 res@mpMinLonF                   = min(lon)


 res@vcGlyphStyle                = "CurlyVector"    ; turn on curley vectors
 res@vcRefMagnitudeF             = refvec           ; define vector ref mag
 res@vcRefLengthF                = 0.045            ; define length of vec ref
 res@vcRefAnnoOrthogonalPosF     = -0.999           ; move ref vector
 res@vcRefAnnoParallelPosF       = 0.12             ; move ref vector
 res@vcMinDistanceF              = 0.019            ; thin vectors
 res@vcRefAnnoString2            = u@units          ; unit string
 res@vcRefAnnoString2On          = True             ; turn on second string

; res@gsnMaximize                 = True             ; maximize plot size

 res@gsnLeftString               = ssh@long_name    ; left string title
 res@gsnRightString              = ssh@units        ; right string title


 plot = gsn_csm_vector_scalar_map_ce(wks, u,v,ssh,res)
end 



