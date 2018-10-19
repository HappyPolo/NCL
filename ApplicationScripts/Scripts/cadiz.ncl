;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************
begin
;************************************
 in = addfile("tpom000_0000.nc","r")
 T=in->Temperature

 in = addfile("vpom000.nc","r")
 v=in->V(0,:,:)

 in = addfile("upom000.nc","r")
 u=in->U(0,:,:)
;***********************************************************
; colormap and land color
;***********************************************************
    wks = gsn_open_wks("ps","cadiz_highres")          ; choose output type
    gsn_define_colormap(wks,"BlAqGrYeOrReVi200")      ; choose colormap
    i = NhlNewColor(wks,.96,.87,.7)                   ; land color
;*************************************************************
; contour plot resources
;*************************************************************
    res                          = True
    res@cnFillOn                 = True	          ; turn on color
    res@cnLinesOn                = False          ; turn off contour lines
    res@cnLevelSpacingF          = 0.10           ; contour interval
;*************************************************************
; color and label bar resources
;*************************************************************
    res@lbLabelStride            = 3              ; stride on label bar
    res@gsnSpreadColors          = True           ; use full colormap
    res@gsnSpreadColorEnd        = -3             ; don't use land color
    res@gsnAddCyclic             = False          ; regional data 
;*************************************************************
; adjust vector thining depending on size of grid
;************************************************************* 
    if( max(T&Latitude)  - min(T&Latitude) .ge. 5 .or. \
        max(T&Longitude) - min(T&Longitude) .ge. 5)
        stride = 4
    else 
        stride = 3
    end if
;*************************************************************
; vector plot resources
;*************************************************************
    res@vcRefAnnoPerimOn        = False
    res@vcGlyphStyle            = "CurlyVector"   ; curly vector style
    res@vcRefMagnitudeF         = 0.15            ; mag of ref vector
    res@vcRefLengthF            = 0.05            ; length of ref vector
    res@vcLineArrowHeadMaxSizeF = 0.013           ; arrow head size
    res@vcLineArrowThicknessF   = 1.3             ; arrow thickness
    res@vcRefAnnoString2        = "m/s"           ; unit string
    res@vcRefAnnoString2On      = True            ; turn on second string
    res@vcRefAnnoOrthogonalPosF = -0.999          ; move ref vector

    res@gsnScalarContour        = True            ; want vectors over contours
;**************************************************
; map resources
;**************************************************
    res@mpOutlineOn          = True                     ; turn on outline
    res@mpDataBaseVersion    = "HighRes"                ; use GMT coastline

    res@mpMaxLatF            = max(u&Latitude)          ; zoom in on region
    res@mpMinLatF            = min(u&Latitude)
    res@mpMinLonF            = min(u&Longitude)
    res@mpMaxLonF            = max(u&Longitude)
;**************************************************
; adjust lat/lon labeling depending on size of grid
;************************************************** 
    if( max(u&Latitude) - min(u&Latitude) .le. 5)
       res@gsnMajorLatSpacing   = 1
    else 
       res@gsnMajorLatSpacing   = 3
    end if

    if( max(u&Longitude) - min(u&Longitude) .le. 7)
       res@gsnMajorLonSpacing   = 1
    else
       res@gsnMajorLonSpacing   = 3
    end if
;**************************************************
; strings and font heights
;************************************************** 
    font_height                 = 0.015
    res@tmYLLabelFontHeightF    = font_height
    res@tmXBLabelFontHeightF    = font_height

    res@tiMainString            = "POM Current (m/s) over Temp (Deg C)"
    res@tiMainFontHeightF       = 1.25 * font_height

    res@gsnLeftString           = "Depth = 0000 m"
    res@gsnRightString          = "Date = 20010312" 
    res@gsnCenterString         = "Tau = 000"
    res@gsnMaximize             = True
;**************************************************
; assign required attributes
;**************************************************
    u&Longitude@units    = "degrees_east"
    v&Longitude@units    = "degrees_east"
    u&Latitude@units     = "degrees_north"
    v&Latitude@units     = "degrees_north"
    T&Longitude@units    = "degrees_east"
    T&Latitude@units     = "degrees_north"
;**************************************************
; fix bug in data 
;**************************************************
    u@_FillValue    = 0.0
    v@_FillValue    = 0.0
    T@_FillValue    = 0.0

    u@_FillValue    = -999
    v@_FillValue    = -999
    T@_FillValue    = -999
;**************************************************
; create plots
;**************************************************
   plot = gsn_csm_vector_scalar_map(wks,u(::stride,::stride),\
                                        v(::stride,::stride),T,res)
end


