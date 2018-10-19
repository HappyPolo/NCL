;***********************************************
; raster_7.ncl
;
; Concepts illustrated:
;   - Drawing raster contours
;   - Generating dummy data
;   - Drawing markers and text at data locations
;   - Turning off tickmarks, but keeping the labels
;***********************************************

; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Create some dummy data.
  nx   = 8
  ny   = 10
  data = generate_2d_array(10, 10, -8, 8, 0, (/ny,nx/))
  y    = fspan(-2.25,2.25,ny)
  x    = fspan(-60,60,nx)

  data!0 = "y"
  data!1 = "x"
  data&y = y
  data&x = x

;---Open png for graphics.
  wks  = gsn_open_wks("png","raster")

  res                      = True
  res@gsnMaximize          = True          ; Maximize plot in frame.
  res@gsnFrame             = False         ; Turn off so we can add markers and text
  res@cnFillOn             = True          ; Turn on contour fill
  res@cnFillMode           = "RasterFill"  ; Turn on raster fill
  res@cnLinesOn            = False         ; Turn off contour lines
  res@cnFillPalette        = "NCV_bright"

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -7
  res@cnMaxLevelValF       =  7
  res@cnLevelSpacingF      =  1
  res@lbOrientation        = "vertical"


  res@tmXBMajorLengthF     = 0.0
  res@tmYLMajorLengthF     = 0.0
  res@tmXBMinorOn          = False
  res@tmYLMinorOn          = False

  res@tiMainString         = "Dots indicate data locations"

  plot = gsn_csm_contour(wks,data,res)

;---Draw text and markers at data locations
  txres               = True
  mkres               = True
  txres@txFontHeightF = 0.01
  txres@txJust        = "TopCenter"  ; text will be drawn under the marker
  mkres@gsMarkerIndex = 16 ; filled circle

  do j=0,ny-1
    do i=0,nx-1
      gsn_polymarker(wks,plot,x(i),y(j),mkres)
      gsn_text(wks,plot,"  ~C~"+data(j,i),x(i),y(j),txres)
    end do
  end do
  frame(wks)
end
