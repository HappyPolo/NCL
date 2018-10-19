;----------------------------------------------------------------------
;  mapoutlines_5_zoom.ncl
;----------------------------------------------------------------------
;
; Concepts illustrated:
;   - Compares different map resolutions for a world map
;   - Drawing a world map using the low resolution map outlines
;   - Drawing a world map using the medium resolution map outlines
;   - Drawing a world map using the high res resolution map outlines
;   - Drawing a world map using shapefiles
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Zooming in on a cylindrical equidistant map
;   - Zooming in on a lambert conformal map
;----------------------------------------------------------------------
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
; set HAVE_RANGS to False
;----------------------------------------------------------------------
; The shapefile in this example was downloaded from:
;
;    http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/
;
; It contains many shapefiles, so you need to look at the 
; GSHHS_SHP/README.txt file to see which one is best for you.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Check if RANGS/GSHHS (HighRes) database is available.
  rangs_dir  = ncargpath("rangs")
  rangs_file = "gshhs(0).rim"
  if(.not.fileexists(rangs_dir + "/" + rangs_file)) then
     HAVE_RANGS = False
     print("You don't seem to have the RANGS database installed.")
     print("It will be excluded for this example.")
     print("See http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml for")
     print("information on downloading this database.")
  else
     HAVE_RANGS = True
  end if


  wks  = gsn_open_wks("png","mapoutlines_zoom")  ; send graphics to PNG file

  res              = True

  res@gsnDraw      = False    ; Will panel later
  res@gsnFrame     = False
  res@mpFillOn     = False
  res@mpLimitMode  = "LatLon"

  res1              = res
  res1@mpProjection = "LambertConformal"
  res1@mpMinLonF    = -15.
  res1@mpMaxLonF    =  15
  res1@mpMinLatF    =  40.
  res1@mpMaxLatF    =  70.

  res2              = res
  res2@mpMinLonF    = 110   ;110
  res2@mpMaxLonF    = 130   ;170
  res2@mpMinLatF    =   0   ;10
  res2@mpMaxLatF    =  20   ; 60

  plots_set1 = new(4,graphic)
  plots_set2 = new(4,graphic)
;----------------------------------------------------------------------
; First plot
;----------------------------------------------------------------------
  plots_set1(0) = gsn_csm_map(wks,res1)
  plots_set2(0) = gsn_csm_map(wks,res2)

;----------------------------------------------------------------------
; Second plot
;----------------------------------------------------------------------
  res1@mpDataBaseVersion = "MediumRes"
  res2@mpDataBaseVersion = "MediumRes"

  plots_set1(1) = gsn_csm_map(wks,res1)
  plots_set2(1) = gsn_csm_map(wks,res2)

;----------------------------------------------------------------------
; Third plot
;----------------------------------------------------------------------
  if(HAVE_RANGS) then
    res1@mpDataBaseVersion = "HighRes"
    res2@mpDataBaseVersion = "HighRes"

    plots_set1(2) = gsn_csm_map(wks,res1)
    plots_set2(2) = gsn_csm_map(wks,res2)
  end if

;----------------------------------------------------------------------
; Fourth plot - we'll add shapefile outlines to this one
;----------------------------------------------------------------------
  res1@mpOutlineOn = False
  res2@mpOutlineOn = False

  plots_set1(3) = gsn_csm_map(wks,res1)
  plots_set2(3) = gsn_csm_map(wks,res2)

;----------------------------------------------------------------------
; GSHHS shapefiles downloaded from
;
;    http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhg/latest/
;
; There are several *.shp files, so look at the README file 
; to decide which one you want
;----------------------------------------------------------------------
  dir      = "GSHHS_shp/"
  filename = "l/GSHHS_l_L1.shp"

  dum1 = gsn_add_shapefile_polylines(wks,plots_set1(3),dir+filename,True)
  dum2 = gsn_add_shapefile_polylines(wks,plots_set2(3),dir+filename,True)

;---Panel all four plots on one page
  pres                                          = True
  pres@gsnMaximize                              = True
  pres@gsnPanelFigureStrings                    = (/"LowRes (default)","MediumRes","HighRes (RANGS)",filename/)
  pres@gsnPanelFigureStringsFont                = "helvetica-bold"
  pres@gsnPanelFigureStringsBackgroundFillColor = "yellow"

  pres@txString                                 = "Map outline comparison with shapefile"
  pres@txFont                                   = "helvetica-bold"
  pres@txFontHeightF                            = 0.03
  pres@amJust                                   = "TopLeft"    ; can use gsnPanelFigureStringsJust in V6.4.0

; In NCL Version 6.4.0, you can use these four resources instead of
; the above four resources to to set the main title and figure
; string options.
; pres@gsnPanelMainString                       = "Map outline comparison with shapefile"
; pres@gsnPanelMainFont                         = "helvetica-bold"
; pres@gsnPanelMainFontHeightF                  = 0.03 
; pres@gsnPanelFigureStringsJust                = "TopLeft"    ; can use this in V6.4.0 instead of amJust

  gsn_panel(wks,plots_set1,(/2,2/),pres)
  gsn_panel(wks,plots_set2,(/2,2/),pres)
end
