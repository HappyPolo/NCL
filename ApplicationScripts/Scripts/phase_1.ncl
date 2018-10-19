;----------------------------------------------------------------------
; phase_1.ncl
;
; Concepts illustrated:
;   - Drawing a "phase" contour plot
;   - Using "overlay" to overlay multiple contour plots
;   - Using "setvalues" to set resource values
;   - Using "where" to set maximum data values to -1
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Create dummy data z to have bands of values:
;    0,10,20,...,360,0,10, ...,360,5,10,20,...
;
  nz = 78
  i  = (ispan(0,nz-1,1)%37) * 10.
;
; The "ind" line will cause our values to be 5,10,20,...,360,5,10,... 
;
;  i(ind(i.eq.0)) = 5       ; At value 0, set to 5.
;
  z  = new((/nz,nz/),float)
  z  = conform(z,i,0)

;
; Separate the values of z into two new arrays such that neither
; of the new arrays will contain both the original min and max
; of z, but that there is some overlap in values.
;
  zmin  = min(z)
  zmax  = max(z)
  third = (zmax-zmin)/3.
  mid1  = zmin + third
  mid2  = zmax - third

;---Set max(z) to -1, so there's no "banding" at the cyclic point.
  newz  = where(z.eq.max(z),-1,z)

;---Top 2/3 of the data
  z2    = where(mid1.lt.z.and.z.le.zmax,z,z@_FillValue)

;---Bottom 2/3 of the data, with max(z) reset to -1.
  z3    = where(newz.le.mid2,newz,newz@_FillValue)

;---Begin graphics.
  wks = gsn_open_wks("png","phase")

  res                       = True
  res@gsnMaximize           = True
  res@gsnPaperOrientation   = "Portrait"

  res@cnLinesOn            = False
  res@cnFillOn             = True
  res@cnFillPalette        = "rainbow"

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = ispan(2,360,10)

  res@lbOrientation        = "Vertical"


;---Draw the original just to see what it looks like.
  res@tiMainString = "Full data plotted. Note bands~C~  at roughly y=37 and y=73" 
  plot = gsn_csm_contour(wks,z,res)

;---Create the two incomplete plots individually, but don't draw them.
  res@gsnDraw      = False
  res@gsnFrame     = False
  res@tiMainString = "Top 2/3 data plotted"
  plot1 = gsn_csm_contour(wks,z2,res)

  res@tiMainString = "Bottom 2/3 data plotted"
  plot2 = gsn_csm_contour(wks,z3,res)

;---Create a panel plot
  pres                     = True
  pres@gsnMaximize         =  True
  pres@gsnPaperOrientation = "Portrait"
  gsn_panel(wks,(/plot1,plot2/),(/2,1/),pres)

;
; Draw the two "incomplete" plots, which together should
; make a complete plot.
;
  setvalues plot2 
   "tiMainString" : "Bottom and top 2/3 data overlaid"
  end setvalues

;---plot1 will become part of plot2
  overlay(plot2,plot1)
  draw(plot2)
  frame(wks)
end
