;================================================;
;  maponly_23.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing all the map projections
;   - Paneling multiple plots on a page
;   - Explicitly setting the fill colors for land, ocean, and inland water
;   - Changing the map grid lines to dashed lines
;   - Masking map grid lines so they don't go over land
;
;=================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin

  wks  = gsn_open_wks("png","maponly")          ; send graphics to PNG file
  gsn_define_colormap(wks,(/"white","black","tan","LightBlue","Blue"/))

;
; As of V5.1.0, these are the 17 available map projections.
;
;   Aitoff
;   AzimuthalEquidistant
;   CylindricalEqualArea
;   CylindricalEquidistant
;   Gnomonic
;   Hammer
;   LambertConformal
;   LambertEqualArea
;   Mercator
;   Mollweide
;   Orthographic
;   PseudoMollweide
;   Robinson
;   RotatedMercator
;   Satellite
;   Stereographic
;   WinkelTripel
;

;
; Grouped by shape. This is so we can panel them better.
;
;   0 = round
;   1 = square
;   2 = oval
;   3 = rectangular
;
  nshapes             = 4
  max_projs_per_type = 6
  shape_projs = new((/nshapes,max_projs_per_type/),string)

; Round
  shape_projs(0,:) = (/"Orthographic", "LambertEqualArea", \
                       "AzimuthalEquidistant", "Satellite", "missing", \
                       "missing"/)

; Square
  shape_projs(1,:) = (/"Stereographic", "Gnomonic", "Mercator", \
                       "LambertConformal", "RotatedMercator", \
                       "missing"/)

; Oval
  shape_projs(2,:) = (/"PseudoMollweide", "Robinson", "Aitoff", "Hammer", \
                       "Mollweide", "WinkelTripel"/)

; Rectangular
  shape_projs(3,:) = (/"CylindricalEquidistant", "CylindricalEqualArea", \
                       "missing", "missing", "missing", "missing"/)

  res             = True

  res@gsnMaximize            = True
  res@gsnDraw                = False
  res@gsnFrame               = False

  res@mpOutlineOn            = True
  res@mpPerimOn              = False

  res@mpGridAndLimbOn        = True
  res@mpGridLineDashPattern  = 2
  res@mpGridMaskMode         = "MaskLand"

  res@mpLandFillColor        = "tan"
  res@mpOceanFillColor       = "LightBlue"
  res@mpInlandWaterFillColor = "Blue"

;  res@mpDataBaseVersion      = "MediumRes"   ; This makes script run slower.

;
; Loop through each group of projections and draw them in a panel.
;
; We may have to tweak some of the paneled plots since the
; maps are slightly different sizes.
;
  pres             = True
  pres@gsnMaximize = True

  do ns = 0,nshapes-1

    nprojs = num(.not.ismissing(shape_projs(ns,:)))
    map    = new(nprojs,graphic)

    do np = 0,nprojs-1

      res@mpProjection = shape_projs(ns,np)
      res@tiMainString = shape_projs(ns,np)
      res@tiMainFont   = "helvetica"          ; default is bold

      map(np) = gsn_csm_map(wks,res)
    end do
    if(ns.eq.3) then
      pres@gsnPanelXF = (/-1,0.07/)      ; Scoot 2nd plot to right a little
      gsn_panel(wks,map,(/2,1/),pres)
      delete(pres@gsnPanelXF)
    else
      if(ns.eq.2) then
        gsn_panel(wks,map,(/3,2/),pres)
      else
        if(nprojs.le.4) then
          gsn_panel(wks,map,(/2,2/),pres)
        else
          gsn_panel(wks,map,(/2,3/),pres)
        end if
      end if
    end if
    delete(map)
  end do
end
