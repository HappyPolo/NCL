;----------------------------------------------------------------------
; newcolor_13.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Drawing panelled contour plots using four different color maps
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
; NOTE: This example will only work with NCL V6.1.0 and later.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate some dummy data.
  nplots      = 4
  nx          = 129
  ny          = 129
  data        = new((/nplots,nx,ny/),float)
  data(0,:,:) = generate_2d_array(10, 10, -19,   19, 0, (/nx,ny/))
  data(1,:,:) = generate_2d_array(10, 10, -27,   30, 1, (/nx,ny/))
  data(2,:,:) = generate_2d_array(10, 10,  -5,    5, 2, (/nx,ny/))
  data(3,:,:) = generate_2d_array(10, 10,   0, 1000, 3, (/nx,ny/))

  wks  = gsn_open_wks("png","newcolor") ; send graphics to PNG file

  res = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@cnFillOn            = True
  res@cnLinesOn           = False

  colormaps = (/"GreenYellow","ncl_default","BlWhRe","BlGrYeOrReVi200"/)

  plots = new(nplots,graphic)
  do n=0,nplots-1
    res@cnFillPalette = colormaps(n)  ; Assign a colormap to a contour plot
    res@tiMainString  = colormaps(n)
    plots(n) = gsn_csm_contour(wks,data(n,:,:),res)
  end do

;---Panel the four plots
  pres             = True
  pres@gsnMaximize = True
  gsn_panel(wks,plots,(/2,2/),pres)
end
