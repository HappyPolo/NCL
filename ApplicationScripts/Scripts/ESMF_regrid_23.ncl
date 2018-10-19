;----------------------------------------------------------------------
; ESMF_regrid_23.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid(_with_weights)
;   - Interpolating satellite data to a rectilinear grid.
;   - Applying a scale equation to unsigned short data.
;   - Generating lat/lon arrays based on information on HDF4 file.
;   - Drawing a Robinson map projection
;----------------------------------------------------------------------
; Source: http://oceandata.sci.gsfc.nasa.gov/MODIST/L3SMI/2006/066/
;         Daily Mapped 4-km and 9-km files in HDF format
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually 
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl" 

begin
;---Name of HDF4 file with data to regrid and lat/lon information.
   fili = "T2006066.L3m_DAY_SST_9.hdf"

;---Data is unsigned short and needs to be scaled
   f = addfile (fili, "r")

   l3m            = f->l3m_data                    
   l3m@_FillValue = -1H
   l3m_scale      = (l3m*f@Slope) + f@Intercept
   l3m_scale@_FillValue = default_fillvalue(typeof(l3m_scale))
   delete(l3m)

   dims   = dimsizes(l3m_scale)
   NLAT   = dims(0)
   MLON   = dims(1)

;---Latitude values go from north to south
   lat       = f@SW_Point_Latitude + ispan(NLAT-1,0,1)*f@Latitude_Step
   lat@units = "degrees_north"   ; f@Latitude_Units = "degrees North"

   lon       = f@SW_Point_Longitude + ispan(0,MLON-1,1)*f@Longitude_Step
   lon@units = "degrees_east"   ; f@Longitude_Units = "degrees East"

   l3m_scale!0    = "lat"                 ; name dimensions
   l3m_scale!1    = "lon"
   l3m_scale&lat  =  lat                  ; create coordinate variables
   l3m_scale&lon  =  lon

   l3m_scale@long_name = f@Parameter  
   l3m_scale@units     = f@Units
   l3m_scale@Measure   = f@Measure

;---Check for presence of weights file. Use if available (faster).
   wgt_filename = "MODIST_to_0.5deg.nc"
   if(isfilepresent(wgt_filename)) then
     HAVE_WGTS = True
     print("----------------------------------------------------------------------")
     print("Weights file '" + wgt_filename + "' is present.")
     print("Will use this for regridding using ESMF_regrid_with_weights.")
     print("----------------------------------------------------------------------")
   else
     HAVE_WGTS = False
     print("----------------------------------------------------------------------")
     print("Weights file '" + wgt_filename + "' is NOT present.")
     print("Will generate file with ESMF_regrid.")
     print("----------------------------------------------------------------------")
   end if

;---Interpolate to a 0.5x0.5 grid
   opt                = True
   opt@ForceOverwrite = True
;   opt@Debug          = True

   if(HAVE_WGTS) then
     opt@DstGridType = "rectilinear"
     l3m_regrid      = ESMF_regrid_with_weights (l3m_scale, wgt_filename, opt)
   else
     opt@DstGridType = "0.5deg"
     opt@WgtFileName = wgt_filename
     opt@SrcMask2D   = where(.not.ismissing(l3m_scale),1,0)
     l3m_regrid      = ESMF_regrid (l3m_scale, opt)
   end if

   l3m_regrid@long_name  =  l3m_scale@long_name + " (0.5x0.5)"

   printVarSummary(l3m_regrid)
   printMinMax(l3m_scale, True)
   printMinMax(l3m_regrid, True)

;***************************************************************
; Create plot 
;***************************************************************
   wks    = gsn_open_wks("png", "ESMF_regrid")   ; send graphics to PNG file
   
   res                      = True     ; plot mods desired
   res@gsnDraw              = False    ; don't draw
   res@gsnFrame             = False    ; don't advance frame
     
   res@cnFillOn             = True     ; turn on color fill
   res@cnFillPalette        = "amwg256" ; set color map
   res@cnLinesOn            = False    ; turn of contour lines
   res@cnFillMode           = "RasterFill" ; Raster Mode
   res@cnLinesOn            =  False       ; Turn off contour lines
   res@cnLineLabelsOn       =  False       ; Turn off contour lines
   res@cnMissingValFillColor= "background" ; "foreground"

   mmi = nice_mnmxintvl(min(l3m_scale),max(l3m_scale),20,False)
   res@cnLevelSelectionMode = "ManualLevels" 
   res@cnMinLevelValF       = mmi(0)
   res@cnMaxLevelValF       = mmi(1)
   res@cnLevelSpacingF      = mmi(2)

   res@lbLabelBarOn         = False        ; turn off individual labelbars
     
   res@mpCenterLonF         = 0.           ; 210.
   res@mpFillOn             = True 
   res@mpLandFillColor      = "grey"              ; color of land
   res@mpFillDrawOrder      = "PostDraw"
   res@mpPerimOn            = False	     
   res@mpProjection         = "Robinson"       
   res@mpGridAndLimbOn      = True 
   res@mpGridLatSpacingF    =  30        
   res@mpGridLonSpacingF    =  30.      
   res@mpGridLineDashPattern=  11         ; 0 - solid,  1/2/11 - dash    
   res@mpGridLineThicknessF = 0.5

   res@gsnAddCyclic         = False
 
;---Create two plots for panelling.
   plot    = new ( 2 , "graphic")
   plot(0) = gsn_csm_contour_map(wks,l3m_scale, res)
   plot(1) = gsn_csm_contour_map(wks,l3m_regrid, res)

   resP                     = True
   resP@gsnMaximize         = True                ; make ps/eps/pdf large
   resP@gsnPanelLabelBar    = True                ; add common colorbar
   resP@lbLabelFontHeightF  = 0.0175              ; change font size
   resP@txString            = fili
   gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
end

