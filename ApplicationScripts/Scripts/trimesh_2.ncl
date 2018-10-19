;*******************************************
; trimesh_2.ncl
;*******************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
;  This North Carolina data is from the Naval Research Laboratory at
;  the Stennis Space Center. For more information about this grid,
;  see the article "Application of a Shelf-Scale Model to Wave-Induced
;  Circulation: Rip Currents" (Mark Cobb and Cheryl Ann Blain,
;  Ocean Dynamics and Prediction Branch).
;
  f = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/ctnccl.nc","r")

  wks = gsn_open_wks("png","trimesh")          ; send graphics to PNG file

  res                     = True
  res@gsnMaximize         = True

  res@sfXArray            = f->lon
  res@sfYArray            = f->lat
  res@sfElementNodes      = f->ele
  res@sfFirstNodeIndex    = 1

  res@cnFillOn            = True
  res@cnFillPalette       = "gui_default"      ; set color map
  res@cnFillMode          = "RasterFill"
  res@cnRasterSmoothingOn = True

;
; First create just a contour plot so we can later retrieve
; the start/end limits of the actual location of the  data.
; Don't draw the contour plot or advance the frame.
;
  res@gsnDraw  = False
  res@gsnFrame = False

  contour = gsn_csm_contour(wks,f->dat,res)
;
; Make sure gsnDraw and gsnFrame are on for the next plot.
;
  res@gsnDraw  = True
  res@gsnFrame = True

;
; Get ready to overlay on a cylindrical equidistant map.
;
; Retrieve the actual start and end limits of the data
;
  getvalues contour@data
    "sfXCActualStartF" : xs
    "sfXCActualEndF"   : xe
    "sfYCActualStartF" : ys
    "sfYCActualEndF"   : ye
  end getvalues

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
  res@mpDataBaseVersion     = "HighRes"     ; "MediumRes" will run faster.
  res@mpLimitMode           = "LatLon"
  res@mpMinLonF             = xs
  res@mpMaxLonF             = xe
  res@mpMinLatF             = ys
  res@mpMaxLatF             = ye
  res@mpPerimOn             = False

  res@pmTickMarkDisplayMode = "Always"        ; Turn on map tickmarks.

  map = gsn_csm_contour_map(wks,f->dat,res)
end
