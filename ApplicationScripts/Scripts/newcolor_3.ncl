;----------------------------------------------------------------------
; newcolor_3.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Drawing partially transparent markers
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
; Adapted from example "opacity_1.ncl" to show how to achieve the
; same result using NCL's new color capabilities; ImageMagick and 
; external processing are no longer required.
;
; The commented "WKSCOLOR" strings below indicate the old
; way of handling color in NCL.
;----------------------------------------------------------------------
; NOTE: This example will only work with NCL V6.1.0 and later.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate some dummy data.
  nx      = 100
  ny      = 100
  dataMin = -23.
  dataMax = 15.
  data    = generate_2d_array(10, 10, dataMin, dataMax ,11, (/ny,nx/))

;---Open a workstation...
  wks = gsn_open_wks("png","newcolor") ; send graphics to PNG file
  ;WKSCOLOR: gsn_define_colormap(wks,"rainbow")
  ;          Use new cnFillPalette resource instead (below)

;---Resources for contours
  res                           = True

  ; No longer want/need separate output frames that are then
  ; composited externally via Imagemagick.
  res@gsnFrame                  = False

  res@gsnMaximize               = True

  res@cnFillOn                  = True         ; Turn on contour fill
  res@cnLinesOn                 = False        ; Turn off contour lines
  res@lbOrientation             = "Vertical"   ; Default is horizontal

  res@tiMainString              = "Opaque markers"
  res@cnFillPalette             = "rainbow"   ; Select a color palette

;---Draw the contour plot.
  plot = gsn_csm_contour(wks,data,res)

;
; Start code for markers.
; 
; First get a clover marker.
;
  clover = NhlNewMarker(wks, "q", 35, 0.0, 0.0, 1.3125, 1., 0.)

;---Marker resources.
  mkres                  = True
  mkres@gsMarkerSizeF    = 0.015
  mkres@gsMarkerOpacityF = 0.2   ; Make the markers translucent!

;---Create some dummy marker positions.
  xpos  = ispan(0,100,1)
  ypos1 = random_uniform(0.,100.,101)
  random_setallseed(36484749, 9494848)
  ypos2 = random_uniform(0.,100.,101)

;
; Draw the two sets of markers twice: the first time in black,
; and the second time in two different shades of gray.  The
; intensity of the gray will determine how opaque the marker
;
; Draw the markers on their own frames; the contours and two sets
; of markers will be overlaid onto one image later.
;
  do iwks = 0,1
;
; The first time in the loop, define a color map with just
; whites and  blacks for two sets of markers.
;
; The second time in the loop define a grayscale color map
; of the same size. The second two gray colors will indicate
; how opaque the black markers should be.
;
    if(iwks.eq.0) then
;
; First time in loop: white, black (dots), black (clover)
;
      ;WKSCOLOR cmap = (/(/1.,1.,1./),(/0.,0.,0./),(/0.,0.,0./)/)
      ;WKSCOLOR: gsn_define_colormap(wks,cmap)
      ; specify colors directly...
      color1 = (/ 0., 0., 0. /)
      color2 = (/ 0., 0., 0. /)
    else
;
; Second time in loop: white, medium gray (dots), darker gray (clover)
;
      ;WKSCOLOR:  cmap = (/(/0.,0.,0./),(/0.5,0.5,0.5/),(/0.6,0.6,0.6/)/)
      ;WKSCOLOR:  gsn_define_colormap(wks,cmap)
      ; specify colors directly...
      color1 = (/ 0.5, 0.5, 0.5 /)
      color2 = (/ 0.6, 0.6, 0.6 /)
    end if

;---Draw the markers
    mkres@gsMarkerIndex      = 16        ; Filled dots
    ;WKSCOLOR:  mkres@gsMarkerColor      = 1         ; first color in color map
    mkres@gsMarkerColor      = color1
    mkres@gsMarkerThicknessF = 1.0       ; Default
    gsn_polymarker(wks,plot,xpos,ypos1,mkres)

    ;WKSCOLOR:  mkres@gsMarkerColor      = 2         ; second color in color map
    mkres@gsMarkerColor      = color2
    mkres@gsMarkerIndex      = clover    ; Circle with "x"
    mkres@gsMarkerThicknessF = 2.0       ; 2x as thick
    gsn_polymarker(wks,plot,xpos,ypos2,mkres)
    ;WKSCOLOR: frame(wks)
  end do

  frame(wks)

; *************************************************************************
; All of the follow code from the original example is no longer needed!
; *************************************************************************
;**
;** This section converts the PS files to jpegs and composites them and
;** overlays them into one big PNG file.
;**
;** Thanks to Tim Scheitlin for showing me this trick!
;**
;** Split the PS file into three PS files.
;**    pict0001.ps - color contours
;**    pict0002.ps - black markers
;**    pict0002.ps - gray markers
;**
;**  delete(wks)                ; Make sure PS file is closed properly
;**  system("psplit opacity.ps")   ; pict0001.ps, pict0002.ps, pict0003.ps
;**
;**;---Convert to jpeg.
;**  do i=1,3
;**    system("convert -density 300 -geometry 1500x1500 pict000" + i + ".ps pict000" + i + ".jpg")
;**  end do
;**
;**;---Composite the black and gray markers and convert to png.
;**  system("composite -compose CopyOpacity pict0003.jpg pict0002.jpg markers.png")
;**
;**;---Overlay on color contours.
;**  system("convert pict0001.jpg markers.png -composite final.jpg")
;**  system("convert -trim final.jpg opacity_1_lg.jpg")
;**
;**;---Clean up
;**  system("/bin/rm pict0001.ps pict0002.ps pict0003.ps")
;**  system("/bin/rm pict0001.jpg pict0002.jpg pict0003.jpg")
;**  system("/bin/rm final.jpg")
end

