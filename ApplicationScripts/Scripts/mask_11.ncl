;*************************************************
; mask_11.ncl
;
; Concepts illustrated:
;   - Drawing the states of Utah, Colorado, Arizona, and New Mexico
;   - Masking out particular areas in a map
;   - Using draw order resources to make sure filled map areas are drawn last
;   - Explicitly setting the areas in a map to fill
;   - Explicitly setting contour levels
;   - Explicitly setting the fill colors for land, ocean, and inland water
;   - Increasing the thickness of map outlines
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  a   = addfile("atmos.nc","r")
  trefht = a->TREFHT(0,:,:)
  
  wks = gsn_open_wks ("png", "mask") ; send graphics to PNG file
  gsn_define_colormap(wks,"amwg_blueyellowred")

  res = True
  res@mpProjection = "Robinson"                              ; use a Robinson projection
  res@mpGeophysicalLineColor = "gray50"                      ; set the Geophysical, USState, and National
  res@mpUSStateLineColor = res@mpGeophysicalLineColor        ; line colors to gray50
  res@mpNationalLineColor = res@mpGeophysicalLineColor 
  res@mpGeophysicalLineThicknessF = 1.5                      ; set the geophysical line thickness (default=1)
  res@mpDataBaseVersion     = "MediumRes"                    ; use the MediumRes version of the map database
  res@mpDataSetName = "Earth..4"                             ; use the Earth..4 data set (introduced in 2008)
  res@mpOutlineBoundarySets = "GeophysicalandUSStates"       ; draw the USStates and geophysical outlines
  res@mpLimitMode = "LatLon"                                 ; limit the area to be drawn by latitude/longitude coordinates
  res@mpMinLonF = 242.                                       ; set the minimum longitude
  res@mpMaxLonF = 260.                                       ; set the maximum longitude
  res@mpCenterLonF = (res@mpMinLonF+res@mpMaxLonF)/2.0       ; set the center longitude of plot
  res@mpMinLatF = 30.                                        ; set the minimum latitude
  res@mpMaxLatF = 45.                                        ; set the maximum latitude
  res@mpPerimOn    = True                                    ; turn on the map perimeter    
  res@mpPerimDrawOrder = "PostDraw"                          ; draw the perimeter last
  
  res@cnLevelSelectionMode = "ExplicitLevels"                ; set explicit contours
  res@cnLevels = ispan(269,293,3)                            ;  that go from 269 to 293 by 3
  res@cnFillOn = True                                        ; color fill the contours
  res@cnFillColors = (/4,5,6,7,8,9,10,11,12,13,14,15/)       ;  with these indices from the loaded colormap 
  res@cnLinesOn = False                                      ; do not draw the lines
  res@cnLineLabelsOn = False                                 ; do not draw the line labels
  res@lbLabelBarOn = False                                   ; do not draw a labelbar under each panel
  
  res@gsnDraw = False                                        ; do not draw the plots
  res@gsnFrame = False                                       ; do not advance the frame 
  
  plot = new(2,graphic)
  plot(0) = gsn_csm_contour_map(wks,trefht,res)              ; draw panel #1 showing full color-filled field
  
  res@mpOutlineBoundarySets = "National"                     ; draw National boundaries
  mask_areas  = (/"Arizona","New Mexico",\                   ; set regions we want to keep/outline
        "Conterminous US:Utah",\
        "Conterminous US:Colorado","Great Salt Lake"/)
  res@mpMaskAreaSpecifiers  = mask_areas                     ; keep these regions
  res@mpOutlineSpecifiers = mask_areas                       ; outline these regions
  res@mpOceanFillColor = 0                                   ; fill the oceans with index 0 (=white)
  res@mpLandFillColor = 0                                    ; fill the land with index 0 (=white)
  res@mpInlandWaterFillColor = 0                             ; fill the inland water with index 0 (=white)
  res@mpFillDrawOrder       = "PostDraw"                     ; fille the ocean, land, and inland water last, but do not 
                                                             ; fill the areas specified in mpMaskAreaSpecifiers
  plot(1) = gsn_csm_contour_map(wks,trefht,res)              ; draw panel #2 showing color-filled mask_areas only
  
  panres = True                                              ; panel resource list
  panres@gsnPanelLabelBar = True                             ; Turn on the panel label bar
  gsn_panel(wks,plot,(/2,1/),panres)                         ; draw the panels, advance the frame
end
