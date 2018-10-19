;================================================;
;  maponly_19.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing Antarctica with ice shelves
;   - Creating a color map using named colors
;   - Turning off tickmarks on a polar stereographic map
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;
;================================================;
;
; Note: you must have NCL version 5.1.0 to run this example!
;
; This example shows how you will be able to get Antarctica
; Ice Shelves in V5.1.0.
;

begin
  wks  = gsn_open_wks("png","maponly") ; send graphics to PNG file

  res                        = True
  res@gsnMaximize            = True    ; Maximize plot in frame
  res@gsnPolar               = "SH"    ; Southern hemisphere
  res@gsnTickMarksOn         = False   ; Turn off map ticks and labels

  res@mpDataSetName          = "Earth..4"   ; Database that contains the
  res@mpDataBaseVersion      = "MediumRes"  ; ice shelves
  res@mpMaxLatF              = -60          ; Zoom in on Antarctica
  res@mpOutlineOn            = True         ; Turn on map outlines
  res@mpFillOn               = True         ; Turn on map fill
  res@mpGridAndLimbOn        = False        ; Turn off grid and limb lines
  res@mpPerimOn              = False        ; Turn off map perimeter

; Set the areas to fill.
  res@mpFillAreaSpecifiers  = (/"Amery Ice Shelf",   \
                                "Dotson Ice Shelf",  \
                                "Lazarev Ice Shelf", \
                                "Fimbul Ice Shelf",  \
                                "Larsen Ice Shelf",  \
                                "Ronne Ice Shelf",   \
                                "Ross Ice Shelf",    \
                                "West Ice Shelf",    \
                                "Land"/)

; Set fill colors for each area in above array
  res@mpSpecifiedFillColors = (/"White", \
                                "White", \
                                "White", \
                                "White", \
                                "White", \
                                "White", \
                                "White", \
                                "White", \
                                "RoyalBlue4"/)

; Draw the map and advance the frame (page)
  map = gsn_csm_map(wks,res)
end
