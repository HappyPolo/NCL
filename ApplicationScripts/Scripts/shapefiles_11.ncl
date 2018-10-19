;----------------------------------------------------------------------
; shapefiles_11.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Creating a mask array using outlines from a shapefile
;   - Attaching markers to a map
;   - Attaching polylines to a map plot
;   - Masking a data array based on a geographical area obtained from a shapefile
;----------------------------------------------------------------------
; This script creates a new data mask based on the outline of the
; United States.  It then draws two plots: the original data,
; and the data with the USA mask.
;
; The "gz_2010_us_020_00_5m.shp" shapefile is from
; http://www.census.gov/geo/www/cob/
;
; The "nationalp010g.shp" shapefile is from:
; http://www.nationalatlas.gov/atlasftp-1m.html#nationp
;
; Try both of these files to see if they work for your purposes.
; The national file is larger, and hence takes longer to process
; (206 wall clock seconds on a Mac versus 17 wall clock seconds.)
;
; Once you create the mask, you can set CREATE_MASK to False so
; it doesn't get created again when you run this script.
;
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;
; This file still has to be loaded manually
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; This is the main code
;----------------------------------------------------------------------
begin
;
; If you already have the mask NetCDF file, set this to False. 
; Creating the mask can be slow!
;
   CREATE_MASK = True  

;---Whether to draw lat/lon points and shapefile outlines
   ADD_LATLON_POINTS      = False
   ADD_SHAPEFILE_OUTLINES = True

;---Name of shapefile containing USA outlines
;  shp_fname = "nationalp010g.shp"
   shp_fname = "gz_2010_us_020_00_5m.shp"

;---Name of file to write mask to or to read mask from.
;  mask_fname = "usa_mask_nationalp010g.nc"
   mask_fname = "usa_mask_5m.nc"

;---Rough area we are interested in. Everything outside this will be masked.
   minlon = -130
   maxlon =  -60
   minlat =   20
   maxlat =   55

;---Read in zonal winds
   a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
   u = a->U(1,:,:)                                ; read July zonal winds

   if(CREATE_MASK) then
     print("Creating the mask file...")

;---Create a new mask using a shapefile of USA
     udims = dimsizes(u) 
     opt             = True
     opt@return_mask = True
;    opt@debug       = True
     opt@minlon      = minlon     ; Makes the shapefile masking
     opt@maxlon      = maxlon     ; go faster.
     opt@minlat      = minlat
     opt@maxlat      = maxlat
     usa_mask        = shapefile_mask_data(u,shp_fname,opt)

;---Write new mask to file
     system("rm -f " + mask_fname)
     fout           = addfile(mask_fname,"c")
     fout->USA_mask = usa_mask
   else
     print("Reading mask off file.")

;---Read the new mask from the NetCDF file 
     fmask    = addfile(mask_fname,"r")
     usa_mask = fmask->USA_mask
   end if

;---Create masked data array
   umask = where(usa_mask.eq.1,u,u@_FillValue)
   copy_VarMeta(u,umask)

;---Start the graphics.
   wks = gsn_open_wks("png", "shapefiles")  ; send graphics to PNG file

   res                       = True     ; plot mods desired
   res@gsnMaximize           = True    
   res@gsnDraw               = False
   res@gsnFrame              = False

   res@mpOutlineOn           = False
   res@cnFillOn              = True     ; turn on color fill
   res@cnLinesOn             = False    ; turn off contour lines
   res@cnLineLabelsOn        = False    ; turn off contour line labels
   res@lbLabelBarOn          = False    ; will turn on in panel

   res@mpDataBaseVersion     = "MediumRes"
   res@mpMinLonF             = minlon
   res@mpMaxLonF             = maxlon
   res@mpMinLatF             = minlat
   res@mpMaxLatF             = maxlat
   res@mpCenterLonF          = (minlon+maxlon)/2.

;---Be sure to use same levels for both plots
   mnmxint = nice_mnmxintvl( min(u), max(u), 25, False)
   res@cnLevelSelectionMode        = "ManualLevels"
   res@cnMinLevelValF              = mnmxint(0)
   res@cnMaxLevelValF              = mnmxint(1)
   res@cnLevelSpacingF             = mnmxint(2)

;---Create (but don't draw) both plots
   res@tiMainString = "Original data"
   plot_orig = gsn_csm_contour_map(wks,u,res)

   res@tiMainString = "Masked data from " + shp_fname
   plot_mask = gsn_csm_contour_map(wks,umask,res)

   if(ADD_LATLON_POINTS) then
;---Set up a resource list to attach the grid points as filled dots
     mkres1                 = True
     mkres1@gsnCoordsAttach = True
     gsn_coordinates(wks,plot_orig,u,mkres1)
 
     mkres2                 = True
     mkres2@gsnCoordsAttach = True
     mkres2@gsnCoordsNonMissingColor = "black"
     mkres2@gsnCoordsMissingColor    = "red"
     gsn_coordinates(wks,plot_mask,umask,mkres2)
   end if

   if(ADD_SHAPEFILE_OUTLINES) then
     lnres  = True
     poly_orig = gsn_add_shapefile_polylines(wks,plot_orig,shp_fname,lnres)
     poly_mask = gsn_add_shapefile_polylines(wks,plot_mask,shp_fname,lnres)
   end if

;---Draw both plot in a panel.
   pres                  = True
   pres@gsnMaximize      = True
   pres@gsnPanelLabelBar = True
   pres@pmLabelBarWidthF = 0.8

   gsn_panel(wks,(/plot_orig,plot_mask/),(/2,1/),pres)

end
