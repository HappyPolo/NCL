;****************************************************
; 2dvertcoords_4.ncl
;****************************************************
; Concepts Illustrated:
;   - Demonstrating alternatives to loops
;   - Using the new color model
;****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;*****************************************************
; Create data to be plotted
;*****************************************************
  n  = 10
  n2 = tointeger(n^2)
  r  = fspan( 4.4, 6.4, n)

  pi = 4. * atan(1.)
  th = fspan( 0, pi/2, n)

  R  = conform_dims((/n,n/), r,0)
  Th = conform_dims((/n,n/),th,1)

  Z  = exp(-((R-5.5)^2)-((Th-0.75)^2))
  X  = R*sin(Th)
  Y  = R*cos(Th)

;    What the above is doing via loops
;  Z = reshape(fspan(0,1.,n2)*0.,(/10,10/))
;  X = reshape(fspan(0,1.,n2)*0.,(/10,10/))
;  Y = reshape(fspan(0,1.,n2)*0.,(/10,10/))
;  do i = 0, n-1
;     do j = 0, n-1
;       X(i,j) = r(i) * sin(th(j))
;       Y(i,j) = r(i) * cos(th(j))
;       Z(i,j) = exp(-((r(i)-5.5)^2)-((th(j)-0.75)^2))
;     end do
;  end do

;*****************************************************
;---Open workstation and change color map
;*****************************************************
  wks = gsn_open_wks("png","2dvertcoords")  ; send graphics to PNG file

  res                   = True
  res@gsnMaximize       = True     ; maximize plot in frame

  res@cnFillOn          = True     ; turn on contour fill
  res@cnFillPalette     = "amwg"   ; set color map
  res@cnLinesOn         = False    ; turn off contour lines
  res@cnLineLabelsOn    = False    ; turn off line labels

; res@cnFillMode        = "RasterFill"
  res@cnFillMode        = "AreaFill"

  res@trGridType        = "TriangularMesh"
  res@tmYLPrecision     = 2

;---Uncomment if you want to specify the contour levels
;  mnmxint = nice_mnmxintvl( min(x), max(x), 18, False)
;  res@cnLevelSelectionMode = "ManualLevels"
;  res@cnMinLevelValF       = mnmxint(0)
;  res@cnMaxLevelValF       = mnmxint(1)
;  res@cnLevelSpacingF      = mnmxint(2)

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0.3
  res@cnMaxLevelValF       = 1.
  res@cnLevelSpacingF      = 0.02

  res@tiMainString         = "Ideal Solar Anvil"

  res@sfXArray	           = X
  res@sfYArray		   = Y 
  plot = gsn_csm_contour(wks,Z,res)
end
