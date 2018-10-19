;*******************************************************
; panel_32.ncl
;
; Concepts illustrated:
;   - Paneling three polar plots on a page
;   - Drawing spaghetti contour plots
;   - Drawing a custom legend on a panel plot
;   - Adding figure strings to paneled plots
;   - Left-justifying paneled plots
;   - Using draw order resources to draw contours under land
;*******************************************************
; This example was contributed by Mira Berdahl of the
; Dept. of Environmental Studies, Rutgers University
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;*******************************************************
begin
;---Set colors for the different experiments
  labels = (/"CTRL 2010-2020",\
             "CTRL 2060-2070",\
             "Exp1 2060-2070",\
             "Exp2 2060-2070"/)
  colors = (/"black","blue","red","green"/)

;************* 
;Read in RCP45
;*************
  f    = addfile("aveSIC_GISS_rcp45_10_20.nc","r")
  sicGISS_1020_rcp45    = f->sic         

  f    = addfile("aveSIC_GISS_rcp45_60_70.nc","r")
  sicGISS_6070_rcp45    = f->sic  

  f    = addfile("aveSIC_HADGEM_rcp45_10_20.nc","r")
  sicHADGEM_1020_rcp45    = f->sic         

  f    = addfile("aveSIC_HADGEM_rcp45_60_70.nc","r")
  sicHADGEM_6070_rcp45    = f->sic

  f    = addfile("aveSIC_MIROC_rcp45_10_20.nc","r")
  sicMIROC_1020_rcp45    = f->sic         

  f    = addfile("aveSIC_MIROC_rcp45_60_70.nc","r")
  sicMIROC_6070_rcp45    = f->sic

  f    = addfile("aveSIC_MIROC_CHEM_rcp45_10_20.nc","r")
  sicMIROC_CHEM_1020_rcp45    = f->sic         

  f    = addfile("aveSIC_MIROC_CHEM_rcp45_60_70.nc","r")
  sicMIROC_CHEM_6070_rcp45    = f->sic

;*********** 
;Read in experiment 1
;***********
  f    = addfile("aveSIC_GISS_G4_60_70.nc","r")
  sicGISS_6070_G4    = f->sic  

  f    = addfile("aveSIC_HADGEM_G4_60_70.nc","r")
  sicHADGEM_6070_G4    = f->sic

  f    = addfile("aveSIC_MIROC_G4_60_70.nc","r")
  sicMIROC_6070_G4    = f->sic

  f    = addfile("aveSIC_MIROC_CHEM_G4_60_70.nc","r")
  sicMIROC_CHEM_6070_G4    = f->sic

;*********** 
;Read in experiment 2
;***********
  f    = addfile("aveSIC_GISS_G3_60_70.nc","r")
  sicGISS_6070_G3   = f->sic  
;
; The "missing_value" attribute for these two variables
; are written as character strings, which is wrong. We
; fixed it here by deleting this attribute and setting 
; the _FillValue attribute instead.
;
  delete(sicGISS_6070_G4@missing_value)
  delete(sicGISS_6070_G3@missing_value)
  sicGISS_6070_G4@_FillValue = 1e20
  sicGISS_6070_G3@_FillValue = 1e20

  f    = addfile("aveSIC_HADGEM_G3_60_70.nc","r")
  sicHADGEM_6070_G3    = f->sic

;********************************************************
;create plots
;********************************************************
  wks = gsn_open_wks("png","panel")     ; send graphics to PNG file

  plot = new(3,graphic)                 ; create graphical array
;**************************************************       

  res                      = True        ; plot mods desired
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'

  res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
  res@cnLevels             = 15               ; which level(s) to plot
  res@cnInfoLabelOn        = False            ; no info label
  res@cnLineLabelsOn       = False            ; no line labels

  res@gsnLeftString            = ""               ; suppress automatic labels
  res@gsnRightString           = ""

;---Set these three resources for the map plots only
  mpres                 = res 
  mpres@mpMinLatF       = 60               ; specify min lat
  mpres@gsnPolar        = "NH"             ; northern hemisphere
  mpres@mpFillDrawOrder = "PostDraw"

;---Start creating the individual plots
  res@cnLineThicknessF = 2
  res@cnLineColor      = colors(0)
  plot(0) = gsn_csm_contour_map_polar(wks,sicGISS_1020_rcp45,mpres)

  res@cnLineColor = colors(1)
  plot_ov = gsn_csm_contour(wks,sicGISS_6070_rcp45,res)

  res@cnLineColor = colors(0)
  plot(1)= gsn_csm_contour_map_polar(wks,sicHADGEM_1020_rcp45,mpres)

  res@cnLineColor = colors(1)
  plot_ov1 = gsn_csm_contour(wks,sicHADGEM_6070_rcp45,res)

  res@cnLineColor = colors(0)
  plot(2)= gsn_csm_contour_map_polar(wks,sicMIROC_1020_rcp45,mpres)

  res@cnLineColor = colors(1)
  plot_ov2 = gsn_csm_contour(wks,sicMIROC_6070_rcp45,res)

  res@cnLineThicknessF = 2
  res@cnLineColor      = colors(2)
  plot_ov4 = gsn_csm_contour(wks,sicGISS_6070_G4,res)
  plot_ov5 = gsn_csm_contour(wks,sicHADGEM_6070_G4,res)
  plot_ov6 = gsn_csm_contour(wks,sicMIROC_6070_G4,res)

  res@cnLineThicknessF = 2
  res@cnLineColor      = colors(3) 
  plot_ov8 = gsn_csm_contour(wks,sicGISS_6070_G3,res)
  plot_ov9 = gsn_csm_contour(wks,sicHADGEM_6070_G3,res)

;---Overlay the contour plots on the contour/map plots
  overlay(plot(0),plot_ov)
  overlay(plot(0),plot_ov4)
  overlay(plot(0),plot_ov8)
  overlay(plot(1),plot_ov1)
  overlay(plot(1),plot_ov5)
  overlay(plot(1),plot_ov9)
  overlay(plot(2),plot_ov2)
  overlay(plot(2),plot_ov6)

; ***************************************************
; create panel
; **************************************************
  resP                       = True                 ; modify the panel plot
  resP@gsnMaximize           = True                 ; maximize in frame
  resP@gsnPaperOrientation   = "Portrait"
  resP@gsnFrame              = False                ; don't advance frame yet
  resP@gsnPanelFigureStrings = "Model"+ispan(1,4,1) ; add strings to panel
  resP@gsnPanelCenter        = False                ; don't center
  gsn_panel(wks,plot,(/2,2/),resP)

;***********************************************
; legend resources
;***********************************************
 lgres                    = True
 lgres@vpWidthF           = 0.2                   ; width of legend (NDC)
 lgres@vpHeightF          = 0.1                   ; height of legend (NDC)
 lgres@lgLineColors       = colors
 lgres@lgPerimOn          = False                 ; turn off perimeter
 lgres@lgDashIndexes      = (/0,0,0,0/)           ; dash indexes
 lgres@lgLineLabelStrings = (/"","","",""/)       ; no labels in lines
 lgres@lgLabelFontHeightF = 0.1                   ; change font height

;**************************************************************
; Draw the legend, indicating the number of items, a label for each
; item, and the X, Y position of the legend in NDC coordinates.
;**************************************************************
  gsn_legend_ndc(wks,4,labels,0.6,0.4,lgres)
  frame(wks)                                   ; now advance the frame
end
