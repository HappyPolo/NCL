;----------------------------------------------------------------------
; This script creates a new data mask based on the outline of
; Greenland.  It then draws two plots: the psl data with the 
; original mask, and the psl data with the new Greenland mask.
;
; Once you create the mask, you can set CREATE_MASK to False so
; it doesn't get created again when you run this script.
;
; The outline of Greenland was obtained by downloading the
; "Greenland" shapefiles from gadm.org/country/.
;
; Note that Greenland has very jagged edges, especially on the east
; side. This causes several data points to drop out, that you
; might expect to be there. You can run the 
; "draw_psl_with_new_mask_and_grid.ncl" script to see the grid points,
; and which ones were left out.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

;----------------------------------------------------------------------
; This is the function that creates a new mask based on the
; shape of Greenland. The "lat1d" and "lon1d" are the one-dimensional
; latitudes and longitudes read off the "BBfC4PLr2035.nc" file.
;----------------------------------------------------------------------
function create_new_mask(lat1d,lon1d)
begin
;---Open shapefile and read lat/lon values.
  f       = addfile("GRL_adm/GRL_adm0.shp", "r")

;---Read data off the shapefile
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)
  geomDims = dimsizes(geometry)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts
  numFeatures   = geomDims(0)

  grl_lon = f->x
  grl_lat = f->y
  ngrl    = dimsizes(grl_lon)

;---Get the approximate lat/lon box that encloses all of Greenland
  min_grl_lat = min(grl_lat)-5
  max_grl_lat = max(grl_lat)+5
  min_grl_lon = min(grl_lon)-5
  max_grl_lon = max(grl_lon)+5

;
; Get the approximate index values that contain the area of interest.
;
; This will make our gc_inout loop below go faster, because we're
; not checking every single lat/lon point to see if it's within
; the area of interest.
;
  ii_latlon = ind(min_grl_lat.le.lat1d.and.lat1d.le.max_grl_lat.and.\
                  min_grl_lon.le.lon1d.and.lon1d.le.max_grl_lon)
  nii = dimsizes(ii_latlon)

;---Create array to hold new data mask, and set all values to 0 initially.
  data_mask = new(dimsizes(lat1d),integer)
  data_mask = 0

;
; This is the loop that checks every point in lat1d/lon1d to see if it
; is inside or outside of Greenland. If it is inside, then data_mask
; will be set to 1.
;
  ikeep = 0    ; Counter to see how many points were found inside Greenland.
  do n=0,nii-1
    ii = ii_latlon(n)
    do i=0, numFeatures-1  
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
         startPT = segments(seg, segs_xyzIndex)
         endPT   = startPT + segments(seg, segs_numPnts) - 1
         if(data_mask(ii).ne.1.and.\
            gc_inout(lat1d(ii),lon1d(ii),\
                     grl_lat(startPT:endPT),grl_lon(startPT:endPT))) then
           data_mask(ii) = 1
           ikeep = ikeep+1
         end if
       end do
    end do
  end do
  print("Kept " + ikeep + " values")

  return(data_mask)
end

;----------------------------------------------------------------------
; This is the main code
;----------------------------------------------------------------------
begin
   CREATE_MASK = True      ; Whether to create the new mask file.
                           ; If you already have the new mask 
                           ; file, set this to False. Creating the
                           ; mask can be slow!

   DRAW_PLOTS  = True      ; Whether to draw any plots
 
   dirc   = "ncfiles/"                  ; input directory
   filc   = "BBfC4PLr2035.nc"
   film   = "masks_t127_tbbr.nc"

   fc     = addfile(dirc+filc, "r")
   fm     = addfile(dirc+film, "r")
   psl    = fc->psl
   latc   = fc->latitude                ; (rgrid)  ... 24572
   lonc   = fc->longitude               ;
   lonc   = where(lonc.gt.180,lonc-360,lonc)
   amask  = fm->$"cbbr.msk"$(0,:)       ; Antarctic mask, 1 x rgrid

;---Add a _FillValue, and change the units for "psl".
   if(.not.isatt(psl,"_FillValue")) then
     psl@_FillValue = -9999.
   end if
   if(.not.isatt(latc,"_FillValue")) then
     latc@_FillValue = -9999
   end if
   if(isatt(psl,"units").and.psl@units.eq."Pa") then
     psl       = psl * 0.01
     psl@units = "hPa"
   end if

;  printVarSummary(psl)
;  printMinMax(psl,0)

   mask_fname = "greenland_mask.nc"
   if(CREATE_MASK) then
     print("--------------------------------------------------------")
     print("ARPEGE_BB_Greenland_mask.ncl: creating a new mask...")

;---Create a new mask using a shapefile of Greenland
     grl_mask = create_new_mask(latc,lonc)

;---Write new mask to file
     if(isfilepresent(mask_fname)) then
       system("/bin/rm " + mask_fname)
     end if
     fout           = addfile(mask_fname,"c")
     fout->GRL_mask = grl_mask
   else
     print("--------------------------------------------------------")
     print("ARPEGE_BB_Greenland_mask.ncl: reading mask off file.")

;---Read the new mask from the NetCDF file 
     fmask    = addfile(mask_fname,"r")
     grl_mask = fmask->GRL_mask
   end if

  if(.not.DRAW_PLOTS) then
    print("---------------------------------------------------------")
    print("ARPEGE_BB_Greenland_mask.ncl: no plots being created.")
    print("---------------------------------------------------------")
    exit
  end if

  print("---------------------------------------------------------")
  print("ARPEGE_BB_Greenland_mask.ncl: plots being created.")
  print("---------------------------------------------------------")
;
; Start the graphics. We will compare a plot of "psl"
; with the "old" mask, and the "new" mask.
;
   wname = get_script_prefix_name()
   wks   = gsn_open_wks("ps", wname)


   res                       = True     ; plot mods desired
   res@gsnMaximize           = True    
   res@gsnDraw               = False
   res@gsnFrame              = False

   res@cnFillOn              = True     ; turn on color fill
   res@cnLinesOn             = False    ; turn off contour lines
   res@cnLineLabelsOn        = False    ; turn off contour line labels
   res@lbLabelBarOn          = False    ; will turn on in panel

   res@cnLevelSelectionMode  = "ManualLevels"

   res@sfXArray              = lonc 
   res@sfYArray              = latc

   res@gsnPolar              = "NH"     ; North Hemisphere
   res@mpFillOn              = False
   res@mpDataBaseVersion     = "MediumRes"

   nt     = 0                           ; arbitrary
   kl     = 13

   pres                  = True
   pres@gsnMaximize      = True
   pres@gsnPanelLabelBar = True
   pres@pmLabelBarWidthF = 0.8

  mnmxint = nice_mnmxintvl( min(psl(nt,:)), max(psl(nt,:)), 25, False)
  res@cnMinLevelValF  = mnmxint(0)
  res@cnMaxLevelValF  = mnmxint(1)
  res@cnLevelSpacingF = mnmxint(2)/2.   ; twice as many

;---Create plot of data with original mask.
  psl_mask1 = where(amask.eq.0,psl(nt,:),psl@_FillValue)
; printVarSummary(psl_mask1)

  copy_VarAtts(psl,psl_mask1)    ; for titles in plot

  res@tiMainString = filc + " (with original mask)"
  plot_mask1 = gsn_csm_contour_map_polar(wks,psl_mask1, res)

;---Create plot of data with Greenland mask.
  psl_mask2 = where(grl_mask.eq.1,psl(nt,:),psl@_FillValue)
  lat_mask  = where(grl_mask.eq.1,latc,latc@_FillValue)
  copy_VarAtts(psl,psl_mask2)

  res@tiMainString = filc + " (with Greenland mask)"
  res@mpMinLatF    = min(lat_mask)
  res@mpMaxLatF    = max(lat_mask)
  plot_mask2 = gsn_csm_contour_map_polar(wks,psl_mask2, res)

;---Draw both plot in a panel.
  gsn_panel(wks,(/plot_mask1,plot_mask2/),(/1,2/),pres)

end
