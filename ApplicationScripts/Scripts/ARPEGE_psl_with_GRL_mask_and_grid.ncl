;----------------------------------------------------------------------
; This script draws "psl" with the Greenland mask applied. It also
; draws the location of the lat/lon grid points, so you can see which
; ones were masked by the Greenland outline.
;
; This script assumes you already ran the "ARPEGE_BB_Greenland_mask.ncl"
; script in order to create the new Greenland mask.
;
; If you set USE_SHAPEFILE to True, then the map outlines from the
; Greenland shapefile will be drawn instead of the NCL map outlines.
; You must download the Greenland shapefile from gadm.org/country.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

;---This script won't be needed in V6.1.0.
load "./gsn_coordinates.ncl" 

begin
   USE_SHAPEFILE      = True     ; Whether to draw shapefile outlines
   DRAW_LATLON_POINTS = True     ; Whether to draw lat/lon grid locations

   dirc   = "ncfiles/"                        ; input directory
   filc   = dirc + "BBfC4PLr2035.nc"
   film   = "greenland_mask.nc"
   nt     = 0                           ; arbitrary
   kl     = 13

   fc       = addfile(filc, "r")
   fm       = addfile(film, "r")
   psl      = fc->psl
   latc     = fc->latitude                ; (rgrid)  ... 24572
   lonc     = fc->longitude               ;
   grl_mask = fm->GRL_mask

   if(.not.isatt(psl,"_FillValue")) then
     psl@_FillValue = -9999.
   end if
   if(isatt(psl,"units").and.psl@units.eq."Pa") then
     psl = psl * 0.01
     psl@units = "hPa"
   end if

   printVarSummary(psl)
   printMinMax(psl,0)

;---Apply the Greenland mask to "psl" and the lat/lon values
   psl_mask = where(grl_mask.eq.1,psl(nt,:),psl@_FillValue)
   copy_VarAtts(psl,psl_mask)
   latc@_FillValue = default_fillvalue("integer")
   lonc@_FillValue = default_fillvalue("integer")
   lat_mask = where(grl_mask.eq.1,latc,latc@_FillValue)
   lon_mask = where(grl_mask.eq.1,lonc,lonc@_FillValue)

;---Start the graphics
   wname = get_script_prefix_name()
   wks = gsn_open_wks("ps", wname)

   res                       = True     ; plot mods desired
   res@gsnMaximize           = True    
   res@gsnDraw               = False
   res@gsnFrame              = False

   res@cnFillOn              = True     ; turn on color fill
   res@cnLinesOn             = False    ; turn of contour lines
   res@cnLineLabelsOn        = False    ; turn of contour line labels
   res@lbLabelBarOn          = False    ; will turn on in panel

   res@cnLevelSelectionMode  = "ManualLevels"

   res@sfXArray              = lonc 
   res@sfYArray              = latc

   res@mpFillOn              = False
   if(USE_SHAPEFILE) then
     res@mpOutlineOn         = False
   end if

   res@mpMinLatF = min(lat_mask)
   res@mpMaxLatF = max(lat_mask)
   res@mpMinLonF = min(lon_mask)
   res@mpMaxLonF = max(lon_mask)
   res@mpCenterLonF = (res@mpMaxLonF+res@mpMinLonF)/2.

   mnmxint = nice_mnmxintvl( min(psl_mask), max(psl_mask), 25, False)
   res@cnMinLevelValF  = mnmxint(0)
   res@cnMaxLevelValF  = mnmxint(1)
   res@cnLevelSpacingF = mnmxint(2)/2.   ; twice as many

   res@tiMainString    = filc
   plot1 = gsn_csm_contour_map(wks,psl(nt,:), res)
   
   res@tiMainString    = filc + " (with Greenland mask)"
   plot2 = gsn_csm_contour_map(wks,psl_mask, res)

   if(USE_SHAPEFILE) then
;---Add Greenland shapefile outline to plot.
     shape_fname = "GRL_adm/GRL_adm0.shp"
     dum1 = gsn_add_shapefile_polylines(wks,plot1,shape_fname,False)
     dum2 = gsn_add_shapefile_polylines(wks,plot2,shape_fname,False)
   end if

   if(DRAW_LATLON_POINTS) then
;---Set up a resource list to attach the grid points as filled dots
     mkres1                 = True
     mkres1@gsnCoordsAttach = True
     mkres1@gsnCoordsX      = lonc
     mkres1@gsnCoordsY      = latc
     gsn_coordinates(wks,plot1,psl,mkres1)
 
     mkres2                 = True
     mkres2@gsnCoordsAttach = True
     mkres2@gsnCoordsX      = lon_mask
     mkres2@gsnCoordsY      = lat_mask
     gsn_coordinates(wks,plot2,psl_mask,mkres2)
  end if

;
; At this point, you have two plots, both possibly with shapefile
; outlines and/or lat/lon grid locations attached to them. 
;
; This code will draw both of these plots in a panel with a
; common labelbar.
;
   pres                  = True
   pres@gsnMaximize      = True
   pres@gsnPanelLabelBar = True
   pres@pmLabelBarWidthF = 0.8

  gsn_panel(wks,(/plot1,plot2/),(/2,1/),pres)
end
