;***********************************************
; color_13.ncl
;
; Concepts illustrated:
;   - Converting from HSV space to RGB space
;   - Explicitly setting contour levels to uneven levels
;
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;************************************************
; Read the file
;************************************************
  a    = addfile("xieArkin-T42.nc","r")
  prc  = a->prc                                 ; read in data
;************************************************
; create colormap in hue,saturation,value and convert
; to rgbh. hue is a 1D array from [0.0..360.0] , saturation 
; and value are 1D arrays from [0.0..1.0]     
;*************************************************
  wks = gsn_open_wks("png","color")             ; open a workstation and send data to PNG

  cmap = (/ (/220, 0.7, 0.9/), (/200, 0.7, 1.0/), \   
  (/180, 0.6, 1.0/), (/160, 0.4, 1.0/), \   
  (/ 75, 0.9, 1.0/), (/ 70, 0.7, 1.0/), \  
  (/ 60, 1.0, 1.0/), (/ 55, 1.0, 0.9/), \ 
  (/ 50, 1.0, 0.8/), (/ 40, 1.0, 0.8/) /)   

; hsvrgb maps values from the HSV color model to the RGB color model. 
; HSV is a good model for generating smooth color maps. The return value 
; is a 2 dimensional array of rgb color triplets. 
;
; Note: up to version 4.3.1, the function used below was an NCL script
; called "hsv2rgb", which took as input individual h, s, v arrays:
; rgbcmap = hsvrgb(cmap(:,0),cmap(:,1),cmap(:,2).
;
; After V4.3.1, the built-in function hsvrgb was added, which only
; needs one array, containing the HSV values in the rightmost 
; dimension. Use this function instead.
;
  rgbcmap = hsvrgb(cmap)

;************************************************
; create panel plots
;*************************************************
  res                      = True               ; plot options desired

  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnFillPalette        = rgbcmap

  res@cnLevelSelectionMode = "ExplicitLevels"   
  res@cnLevels             = (/0.1,0.2,0.4,0.8,1.6,3.2,6.4,12.8,25.6/)


  res@mpFillOn             = False              ; turn off gray continents
 
  res@mpMaxLatF            =   0.               ; zoom in over Australia
  res@mpMinLatF            = -50.
  res@mpMaxLonF            =  170
  res@mpMinLonF            =  100.

  res@tiMainString         = "colors from hsv " 

  plot = gsn_csm_contour_map(wks,prc(0,:,:), res)  ; create plot
end






