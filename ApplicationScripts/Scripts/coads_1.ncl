;*****************************************************
; coads_1.ncl
;
; Concepts illustrated:
;   - Plotting COADS (Comprehensive Ocean-Atmosphere Data Set) data
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Paneling four plots on a page with a common labelbar
;   - Setting contour levels using a min/max contour level and a spacing
;   - Spanning part of a color map for contour fill
;   - Converting "short" data to "float"
;   - Changing the center longitude for a cylindrical equidistant projection
;   - Using draw order resources to make sure filled map areas are drawn last
;   - Using "mask" to set a range of values in your data to missing
;   - Drawing raster contours
;   - Drawing subtitles at the top of a plot
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;*****************************************************
; set parameters
;*****************************************************
  times = (/193001,195001,197001,199001/)            ; times to be plotted 
  nMin   = 3                                         ; min # obs
  panel  = True                                      ; panel or individual


; this script demonstrates how you can set up automatic 
; paneling. In this case for legibility, we are limiting the 
; number of plots to 6
  if (dimsizes(times).le.1 .or. dimsizes(times).gt.6) then       
      print ("You must have between 1 and 6 times selected")
      exit
  end if
;*****************************************************
; create a nice time array and use it to get
; array indices of certain times
;*****************************************************
  yyyymm = timeCoads2YYYYMM(1800,1997,"float")

  loc= new (dimsizes(times), integer) ; subscript indices
  do i=0,dimsizes(loc)-1
     loc(i) = ind(yyyymm.eq.times(i))
  end do
;*****************************************************
; get data
;*****************************************************
  fa     = addfile("air.mean.nc","r")
  fb     = addfile("air.nobs.nc","r")
 
; read only times from above
  air  = short2flt( fa->air(loc,:,:))              ; air temp        
  nobs = short2flt( fb->air(loc,:,:))              ; # obs for air
                           
; replace original coordinate variable with one created above
  air&time  = yyyymm(loc) 
  nobs&time = air&time

; filter out geographic locations that have < nMin observations
  air  = mask(air,nobs.ge.nMin,True)
;***************************************
; create plot
;***************************************  
  nplot = dimsizes(times)
  plot = new (nplot, graphic)                   ; create graphical array

  wks  = gsn_open_wks("png","coads")            ; send graphics to PNG file
  cmap = read_colormap_file("rainbow")          ; read color data
  
  res                      = True               ; plot mods desired


  res@cnFillOn             = True               ; color contours
  res@cnFillPalette        = cmap(38:,:)        ; set color map
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnFillMode           = "RasterFill"       ; Raster Mode
  
  res@gsnDraw              = False              ; do not draw individual plots
  res@gsnFrame             = False              ; do not advance frame

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       =   2.               ; set min contour level
  res@cnMaxLevelValF       =  30.               ; set max contour level
  res@cnLevelSpacingF      =   2.               ; set contour spacing

  res@mpFillDrawOrder      = "PostDraw"         ; plot land last
  res@mpCenterLonF         = 180                ; centers plot at 180 vs 0

  res@lbLabelBarOn         = False              ; turn off individual cb's

; create individual plots to be put in panel
  do i=0,nplot-1
     res@gsnRightString      = times(i) 
     plot(i) = gsn_csm_contour_map_ce(wks,air({times(i)},:,:),res)
  end do
;************************************************
; create panel 
; http://www.ncl.ucar.edu/Applications//panel.shtml
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@txString         = "COADS: nMin="+nMin    ; common label
  resP@gsnPanelLabelBar = True                   ; add common colorbar
  resP@gsnMaximize      = True                   ; maximize plot

; determine arrangement of plots on the page depending upon their number
  if (nplot.le.3) then
    shape = (/nplot,1/)    ; plots in one column
  end if
  if (nplot.ge.4) then
    shape = (/3,2/)        ; plots in two columns
  end if
  
  gsn_panel(wks,plot,shape,resP)               
end
