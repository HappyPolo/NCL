load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  filename = "FRCCORE2_e_1m_19980101_20071231_thetao.nc"
  f        = addfile (filename, "r")
  thetao   = f->thetao              ; (time_counter, deptht, y, x) 
  lat2d    = f->nav_lat             ; (y,x)
  lon2d    = f->nav_lon             ; (y,x)
  date     = cd_calendar(thetao&time_counter, -3)   ; YYYYMMDDHH

;---Start the graphics
  wks = gsn_open_wks("ps","IPSL_thetao_panel")
  gsn_define_colormap(wks,"rainbow")             ; Change color map

 ;---Set some resources
   res              = True
   res@gsnDraw      = False              ; Don't draw plots; will
   res@gsnFrame     = False              ; panel them later.
   res@gsnMaximize  = True               ; Maximize size of plots.

   res@sfXArray     = lon2d         ; This will position data
   res@sfYArray     = lat2d         ; correctly on map.
   res@gsnAddCyclic = False         ; Cyclic point already added
   res@cnFillOn     = True          ; Turn on contour fill
   res@cnLinesOn    = False         ; Turn off contour lines
   res@cnFillMode   = "RasterFill"  ; Faster than "AreaFill"

;---Fix the contour levels for all plots
   nd = 0
   mnmxspac = nice_mnmxintvl(min(thetao(:,nd,:,:)),max(thetao(:,nd,:,:)),16,0)
   res@cnLevelSelectionMode = "ManualLevels" ; Default is "automaticlevels"
   res@cnMinLevelValF       = mnmxspac(0)
   res@cnMaxLevelValF       = mnmxspac(1)
   res@cnLevelSpacingF      = mnmxspac(2)/2.  ; Twice as many levels

   res@lbLabelBarOn         = False          ; Turn off individual labelbars

;---Loop over four timesteps and create four plots.
   plots = new(4,graphic)
   do nt=0,3     
     res@gsnCenterString = date(nt) + "  z=" + thetao&deptht(nd)
     plots(nt) = gsn_csm_contour_map(wks,thetao(nt,nd,:,:),res)
   end do

;---Set up resources for paneling four plots on one page.
   pres                  = True
   pres@gsnMaximize      = True              ; Maximize paneled plots
   pres@gsnPanelLabelBar = True              ; Turn on panel labelbar
   pres@pmLabelBarWidthF = 0.8               ; Make labelbar longer
   pres@txString         = filename

  gsn_panel(wks,plots,(/2,2/),pres)     ; Draw 2 rows x 2 columns
end
