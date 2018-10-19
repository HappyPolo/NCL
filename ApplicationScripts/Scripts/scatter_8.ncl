;*************************************************
; scatter_8.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot with markers of different colors
;   - Generating dummy data using "random_uniform"
;   - Drawing a labelbar outside an XY plot
;   - Changing the markers in an XY plot
;   - Changing the marker color in an XY plot
;   - Changing the marker size in an XY plot
;   - Manually creating a labelbar
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;----------------------------------------------------------------------
; Function to attach a labelbar outside of an XY plot
;----------------------------------------------------------------------
function attach_labelbar(wks,plot,labels,colors)
local lbres, vph, vpw, nboxes
begin
  nboxes = dimsizes(labels)
  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False          ; Necessary to control sizes
  lbres@lbPerimOn          = False
  lbres@vpWidthF           = 0.2 * vpw     ; labelbar width
  lbres@vpHeightF          = vph           ; labelbar height
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.02          ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
  lbres@lbBoxLinesOn       = False

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)
;
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot.
;                                                                 
  amres                = True
  amres@amParallelPosF = 0.61     ; Move away from plot
  annoid = gsn_add_annotation(plot,lbid,amres)

  return(annoid)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Generate 2D array of random points from 0 to 50.
  ny     = 20
  nx     = 50
  npts   = ny*nx
  data2d = random_uniform(0.1,50,(/ny,nx/))
  x      = ispan(1,nx,1)

  levels  = ispan(0,50,1)
  nlevels = dimsizes(levels)
  labels  = new(nlevels,string)
  labels  = ""
  labels(0::10) = "" + ispan(0,50,10)
  
  print("min/max data = " + min(data2d) + "/" + max(data2d))
  print("# of groups  = " + (nlevels-1))

;---Create new 3D array to hold groupings of values
  data3d = new((/nlevels-1,ny,nx/),typeof(data2d))

;---Group the values by level and put in 3D array.
  do n=0,nlevels-2
    do j=0,ny-1
      ii = ind(data2d(j,:).ge.levels(n).and.data2d(j,:).lt.levels(n+1))
      if(.not.any(ismissing(ii))) then
        data3d(n,j,ii) = data2d(j,ii)
      end if
      delete(ii)
    end do
  end do

;----------------------------------------------------------------------
; Graphics section
;----------------------------------------------------------------------

;---Span the default 256 color map for the markers 
  nstep = 256/nlevels
  colors = ispan(2,256,nstep)

  wks  = gsn_open_wks("png","scatter")              ; send graphics to PNG file

  square = NhlNewMarker(wks, "y", 35, 0.0, 0.0, 1., 0.5, 0.)

;---Create a scatter plot
  res                    = True
  res@gsnDraw            = False        ; Don't draw plot or advance
  res@gsnFrame           = False        ; frame. Will do this later.

  res@tiMainString       = "Scatter plot with grouped markers"

;---Set some marker resources
  res@xyMarkLineMode     = "Markers"
  res@xyMarkerThicknessF = 2.5
  res@xyMarkerColors     = colors
  res@xyMarker           = square     ; this is a filled square

  overlays = new(ny-1,graphic)
  plot = gsn_csm_xy (wks,x,data3d(:,0,:),res)
  do j=1,ny-1
    overlays(j-1) = gsn_csm_xy (wks,x,data3d(:,j,:),res)
    overlay(plot,overlays(j-1))
  end do

;---Attach a labelbar
  labelbar = attach_labelbar(wks,plot,labels,colors)

;---This call resizes the plot and draws it
  maximize_output(wks,False)

end
