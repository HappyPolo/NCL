;************************************
; coast_1.ncl
;************************************
;
; Concepts illustrated:
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Drawing a map using the high resolution map outlines
;   - Drawing three different resolutions for map outlines
;   - Drawing the Strait of Gibraltar using three different resolutions
;   - Zooming in on a particular area on the map
;   - Moving the labelbar away from the plot
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************
begin
;************************************
  in = addfile("tpom000.nc","r")
  t=in->Temperature
;***********************************************************
; create plot
;***********************************************************
  wks = gsn_open_wks("png","coast")          ; send graphics to PNG file
  
  res                          = True
  
  res@cnFillOn                 = True	             ; turn on color
  res@cnFillPalette            = "BlAqGrYeOrReVi200" ; set color map
  res@cnLinesOn                = False             ; turn off contour lines
  res@cnLevelSpacingF          = 0.10              ; contour interval
  res@cnFillDrawOrder          = "PreDraw"         ; draw contours first
  
  res@lbLabelStride            = 3                 ; stride on label bar
  res@gsnAddCyclic             = False             ; regional data 
  
  res@mpMaxLatF                = max(t&Latitude)   ; zoom in on region
  res@mpMinLatF                = min(t&Latitude)
  res@mpMinLonF                = min(t&Longitude)
  res@mpMaxLonF                = max(t&Longitude)
  res@mpLandFillColor          = "wheat2"
  
  res@gsnMajorLatSpacing       = 1                 ; finer labels on axis
  res@gsnMajorLonSpacing       = 1
  
  res@tiMainString             = "Strait of Gibraltar"
  res@gsnCenterString          = "Default Coastline"
  
  
; Note that this geographical region is small enough, that we run into
; the problems with the labels being too small. You can see other
; examples of this issue and associated solutions at "tropical strip
; plots", http://www.ncl.ucar.edu/Applications/tropical.shtml
  
  font_height                  = 0.015             ; make fonts larger
  res@tmYLLabelFontHeightF     = font_height
  res@tmXBLabelFontHeightF     = font_height
  res@tiMainFontHeightF        = 1.25 * font_height
  
  res@pmLabelBarOrthogonalPosF = .1                ; move label bar down
;**************************************************
; assign required attributes
;**************************************************
  t&Longitude@units    = "degrees_east"
  t&Latitude@units     = "degrees_north"
;**************************************************
; fix bug in data 
;**************************************************
  t@_FillValue    = 0.0
  t@_FillValue    = -999
;**************************************************
; create plots
;**************************************************
  plot = gsn_csm_contour_map_ce(wks,t(0,:,:),res)
  
  res@gsnCenterString      = "Medium Coastline"
  res@mpDataBaseVersion    = "MediumRes"                ; use GMT coastline
  plot = gsn_csm_contour_map_ce(wks,t(0,:,:),res)
  
  res@gsnCenterString      = "High Res Coastline"
;
; Note: in order to use the high-resolution coastal database
; (mpDataBaseVersion = "HighRes"), you must download and install RANGS
; (Regionally Accessible Nested Global Shorelines), the multi-resolution
; coastline database, developed by Rainer Feistel from Wessel and
; Smith's GSHHS (Global Self-consistent Hierarchical High-resolution
; Shoreline) database. For more information, visit:
;
;    http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml
;
; If you don't have this database, or don't want to install it, 
; change this resource value to "MediumRes".
;
  res@mpDataBaseVersion    = "HighRes"                ; use GMT coastline
  plot = gsn_csm_contour_map_ce(wks,t(0,:,:),res)
end


