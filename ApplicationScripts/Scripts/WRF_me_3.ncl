;----------------------------------------------------------------------
; WRF_me_3.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Mercator map projection
;   - Using gsn_csm_contour_map to plot WRF-ARW data in its native projection
;   - Paneling three plots on a page
;   - Specifying how many plots to draw in each row
;   - Selecting a different color map for each contour plot
;----------------------------------------------------------------------
; Paneling three different variables at the same time step. Each
; variable is plotted using its own colormap. You can see a gallery
; of color maps at:
;
; http://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml
;
; You can also create your own color map:
;
; http://www.ncl.ucar.edu/Document/Graphics/create_color_table.shtml
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file and read in data
  f     = addfile("wrfout_d01_2003-07-15_00:00:00.nc","r")
  times = wrf_user_getvar(f,"times",-1)
  znu   = f->ZNU(0,:)                          ; (Time, bottom_top)
;
; Read perturbation geopotential, pressure, water vapor 
; at all times and levels
;
  ph    = f->PH                     ; (Time, bottom_top, south_north, west_east)
  p     = f->P                      ; (Time, bottom_top, south_north, west_east)
  q2    = f->Q2                     ; (Time, south_north, west_east )

  wks = gsn_open_wks("png","WRF_me")

  res                       = True             ; plot mods desired
  res@gsnMaximize           = True                 ; maximize plot size
  res@cnFillOn              = True             ; color plot desired
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels

  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False                 ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True                  ; set True for native projections

;---Allocate array for 3 plots
  plts                      = new (3,"graphic")   
;
; Specify (arbitrarily chosen) subscripts 
; This could also be done in a do loop or explicitly specified
;
  nt                        = 0                ; first time step
  kl                        = 3      

;---Tell NCL not to draw or advance frame for individual plots
  res@gsnDraw               = False            ; (a) do not draw 
  res@gsnFrame              = False            ; (b) do not advance 'frame'

  res@cnFillPalette         = "BlAqGrYeOrReVi200"  ; select color map
  res@gsnLeftString         = ph@description+": znu="+znu(kl)
  plts(0)                   = gsn_csm_contour_map(wks,ph(nt,kl,:,:),res)

  res@cnFillPalette         = "SVG_Lindaa07"
  res@gsnLeftString         = p@description+": znu="+znu(kl)
  plts(1)                   = gsn_csm_contour_map(wks,p(nt,kl,:,:),res)
  delete(res@gsnLeftString)            

  res@cnFillPalette         = "BlueYellowRed"
  plts(2)                   = gsn_csm_contour_map(wks,q2(nt,:,:),res)

;---Create panel: panel plots have their own set of resources
  resP                    = True                   ; modify the panel plot
  resP@gsnPanelMainString = f@TITLE+": "+times(nt)      
  resP@gsnMaximize        = True                   ; maximize panel area
  resP@gsnPanelRowSpec    = True                   ; specify 1 top, 2 lower level  
  gsn_panel(wks,plts,(/1,2/),resP)                 ; now draw as one plot

end

