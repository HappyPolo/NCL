;----------------------------------------------------------------------
; color_19.ncl
;
; Concepts illustrated:
;   - Setting the maximum number of contour levels allowed
;   - Reading a color map in order to change some values
;   - Forcing the first contour level to be white
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.4.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 

begin
;
;---Read data off file
  in    = addfile("80.nc","r")
  TS    = in->TS

;----------------------------------------------------------------------
; Create a color-filled contour plot using the "amwg" color map.
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","color")             ; send graphics to PNG file

  res                      = True               ; plot mods desired

  res@cnFillOn             = True               ; turn on color fill
  res@cnFillPalette        = "amwg"             ; set color map
  res@cnLinesOn            = False              ; turn off contour lines
  res@mpFillOn             = False              ; turn off gray filled land

  res@tiMainString = "amwg color map - note tan is repeated"
  plot = gsn_csm_contour_map(wks,TS(0,:,:), res)   ; create plot

;----------------------------------------------------------------------
; Note that in the above plot, NCL chose "nice" contour levels that
; start at 235 and end at 310, with a step of 5. This gives you a color
; bar with 17 boxes.
;
; Since the "amwg" color map only has 16 colors, this means that 
; one of the colors is going to be repeated (the tan color).
;
; In order to avoid this, you can do one of the following:
;
;  1. Choose a color map with more colors
;  2. Set the contour levels yourself to a smaller set of levels
;  3. Set cnMaxLevelCount to something less than the number of colors
;     you have in your color map to force NCL to choose fewer contour
;     levels.
;
; This example uses #3.
;----------------------------------------------------------------------

;---Read the color map as an RGBA array and then get the number of colors
  cmap    = read_colormap_file("amwg")     ; 16 x 4
  ncolors = dimsizes(cmap(:,0))            ; 16

  res@cnMaxLevelCount = ncolors-1       ; make sure NCL chooses 15 or fewer contour levels
  res@tiMainString    = "Force NCL to use fewer contour levels; no repeated colors"
  plot = gsn_csm_contour_map(wks,TS(0,:,:), res)   ; create plot

;----------------------------------------------------------------------
; This section shows how to force the first color in the color bar
; to be white.
;----------------------------------------------------------------------

;---Replace the first color in cmap with white
  cmap(0,:) = namedcolor2rgba("white")

;---Use the RGBA array as the new fill palette
  res@cnFillPalette := cmap      ; Use modified RGB/A array
  res@tiMainString  = "Set first color to white"
  plot = gsn_csm_contour_map(wks,TS(0,:,:), res)   ; create plot

end
