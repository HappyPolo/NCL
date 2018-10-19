; ===========================================
; coneff_12.ncl
;
; Concepts illustrated:
;   - Adding shading or color fill to areas on a contour plot with missing data
;   - Drawing a perimeter around areas on a contour plot with missing data
;   - Explicitly setting contour levels
;   - Changing the color of contour fill patterns
;
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
 f     = addfile ("80.nc", "r")             ; add file
 TS    = f->TS(0,:,:)
; ===========================
; create plot
; ===========================
 wks   = gsn_open_wks ("png", "coneff")        ; send graphics to PNG file

 res                 = True                    ; plot mods desired
 res@gsnDraw         = False                   ; don't draw yet
 res@gsnFrame        = False                   ; don't advance frame yet
 res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
 res@cnLevels        = (/232.7,234.2,238,240,244,248.4,252,258.3,276,286.5,292.1,300,306/)
 res@tiMainOn        = False
 res@cnFillOn        = True                    ; turn on color 
 res@cnFillPalette   = "gui_default"           ; set color map
 res@lbLabelBarOn    = False                   ; will draw a panel label bar instead
 res@cnLinesOn       = False                   ; turn off contour lines
 res@cnLineLabelsOn  = False                   ; tuen off line labels
 
 plot = new(3,graphic)
  
 TS = mask(TS,TS.lt.240,False)     ; create artificial areas of missing data
 plot(0) = gsn_csm_contour_map_ce(wks,TS, res)
 
 res@cnMissingValPerimOn     = True            ; turn on the missing value perimeter
 res@cnMissingValPerimColor  = "red"           ; outline the perimeter red
 res@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
 res@cnMissingValFillColor   = "blue"          ; color fill missing areas blue
 plot(1) = gsn_csm_contour_map_ce(wks,TS, res)
 
 res@cnMissingValFillPattern = 5               ; set the missing value fill pattern to 5
 res@cnMissingValFillScaleF  = 0.8             ; increase the density of the fill pattern (default=1.0)   
; res@cnMissingValPerimOn     = True            ; already turned on above   
 res@cnMissingValPerimColor  = "black"         ; change the missing value perimeter to black
 res@cnMissingValPerimDashPattern = 1          ; set the dash pattern of the missing value perimeter to 1
 res@cnMissingValPerimThicknessF  = 3.0        ; increase the thickness of the missing value perimeter 3X
 plot(2) = gsn_csm_contour_map_ce(wks,TS, res)
 
 panres                     = True
 panres@gsnMaximize         = True             ; maximize the plots
 panres@gsnPanelLabelBar    = True             ; turn on the panel label bar
 panres@gsnPaperOrientation = "portrait"       ; make sure the paper orientation is set to portrait
 panres@lbLabelStride       = 2                ; set the label bar label stride to 2
 gsn_panel(wks,plot,(/3,1/),panres) 
end
