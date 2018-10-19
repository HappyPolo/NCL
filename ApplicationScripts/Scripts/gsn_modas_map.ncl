;***********************************************************************;
; Function : gsn_modas_vector_scalar_map                                ;
;                   wks: workstation object                             ;
;                     u: 2-dimensional data                             ;
;                     v: 2-dimensional data                             ;
;                  data: 2-dimensional scalar data                      ;
;                                                                       ;
; This function is similar to gsn_csm_vector_map_other except it either ;
; colors the vectors according to a scalar field, or it overlays a      ;
; contour plot.                                                         ;
;                                                                       ;
; There's a special resource associated with this function called       ;
; "gsnScalarContour".  If it's set to True, then the scalar field will  ;
; be drawn as a contour plot.  Otherwise, the vectors will be colored   ;
; according to the scalar field. This resource defaults to False.       ;
;***********************************************************************;

function gsn_modas_vector_scalar_map(wks:graphic,u[*][*]:numeric,\
                                        v[*][*]:numeric,data[*][*]:numeric)
begin
;***********************************************************
; Initialize.
;***********************************************************
    font_height = 0.015
;***********************************************************
; hardwire colormap and land color
;***********************************************************
    gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
    i = NhlNewColor(wks,.96,.87,.7)

    if( max(data&Latitude) - min(data&Latitude) .ge. 5 .or. \
        max(data&Longitude) - min(data&Longitude) .ge. 5)
        stride = 4
    else 
        stride = 3
    end if
;*************************************************************
; set some default contour plot resources
;*************************************************************
    res                          = True
    res@cnFillOn                 = True	
    res@cnLinesOn                = False
    res@cnLevelSpacingF          = 0.10 
    res@cnFillDrawOrder          = "Predraw"

    res@sfXArray                 = data&Longitude
    res@sfYArray                 = data&Latitude
;*************************************************************
; set some default color and label bar resources
;*************************************************************
    res@lbLabelStride            = 4
    res@pmLabelBarOrthogonalPosF =-.03

    res@gsnSpreadColors          = True
    res@gsnSpreadColorStart      = 2 
    res@gsnSpreadColorEnd        = -3
    res@gsnAddCyclic             = False  
;*************************************************************
; set some default vector plot resources
;*************************************************************
    res@vcRefAnnoPerimOn        = False
    res@vfXArray                = u&Longitude(::stride)
    res@vfYArray                = u&Latitude(::stride)
    res@vcGlyphStyle            = "CurlyVector"
    res@vcRefMagnitudeF         = 0.18
    res@vcRefLengthF            = 0.05
    res@vcLineArrowHeadMaxSizeF = 0.013
    res@vcLineArrowThicknessF   = 1.3
    res@gsnScalarContour        = True
;**************************************************
; map resources
;**************************************************
    res@mpOutlineOn          = True
    res@mpDataBaseVersion    = "MediumRes"

    res@mpMaxLatF            = max(u&Latitude)
    res@mpMinLatF            = min(u&Latitude)
    res@mpMinLonF            = min(u&Longitude)
    res@mpMaxLonF            = max(u&Longitude)
    
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

    res@tmYLLabelFontHeightF = font_height
    res@tmXBLabelFontHeightF = font_height
;**************************************************
; other resources
;**************************************************
    res@tiMainString            = "POM Current (m/s) over Temp (Deg C)"
    res@tiMainFontHeightF = 1.25 * font_height

    res@gsnLeftString           = "Depth = 0000 m"
    res@gsnRightString          = "Date = 20010312" 
    res@gsnCenterString         = "Tau = 000"
;**************************************************
; assign required attributes
;**************************************************
   u&Longitude@units    = "degrees_east"
   v&Longitude@units    = "degrees_east"
   u&Latitude@units     = "degrees_north"
   v&Latitude@units     = "degrees_north"
   data&Longitude@units = "degrees_east"
   data&Latitude@units  = "degrees_north"
;**************************************************
; fix bug in data 
;**************************************************
   u@_FillValue    = 0.0
   v@_FillValue    = 0.0
   data@_FillValue = 0.0

   u@_FillValue    = -999
   v@_FillValue    = -999
   data@_FillValue = -999
;**************************************************
; create plots
;**************************************************
   plot = gsn_csm_vector_scalar_map(wks,u(::stride,::stride),v(::stride,::stride),data,res)
;****************************************************************  
; Draw all this stuff: map map, subtitles, and tick marks.
;****************************************************************  
  return(plot)

end

