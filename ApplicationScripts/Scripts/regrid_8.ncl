;*************************************************************
; regrid_8.ncl
;
; Concepts illustrated:
;   - Reading a variable off a file and updating its meta data
;   - Interpolating from a global GAUSSIAN grid to a lower resolution
;   - Computing global areal mean values after computing the gaussian weights 
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Paneling three plots vertically on a page
;   - Creating a netCDF file
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
;*************************************************************
; User specified options
;*************************************************************
  PLOT    = True
  netCDF  = True 

  pltDir  = "./"       ; only used if PLOT=True, otherwise ignored
  pltName = "regrid"
  pltType = "ps"       ; x11, ps, pdf, eps, png [v5.2.0]

  ncDir   = "./"       ; only used if netCDF=True, otherwise ignored
  ncFil   = "GPCP_T85"
;*************************************************************
; read 
;*************************************************************
   diri  = "./"
   fili  = "erai.PS.T159.1989.m.01.nc"       ; (lat, lon) => (256,512)=> T159

   f     = addfile(diri+fili, "r")
   x     = f->PS
   x     = x*0.01                            ; change units for plotting reasons
   x@units = "hPa"

  ;printVarSummary(x)
  ;printMinMax(x, True)
;*************************************************************
; perform conservative remapping to two different grid resolutions
;*************************************************************
   opt      = False

   NLATT85  =  128                              ; RES   = "T85"    
   MLONT85  = 2*NLATT85                        
   LATT85   = latGau   (NLATT85, "LAT", "latitude" , "degrees_north")  ;            
   LONT85   = lonGlobeF(MLONT85, "LON", "longitude", "degrees_east" )  ; 1.5E->358.5E
   XT85     = area_conserve_remap_Wrap (x&lon, x&lat, x ,LONT85, LATT85, opt)
;  ---
   NLATT42  =  64                               ; RES   = "T42"    
   MLONT42  =  2*NLATT42                       
   LATT42   = latGau   (NLATT42, "LAT", "latitude" , "degrees_north")  ; 87S -> 87N
   LONT42   = lonGlobeF(MLONT42, "LON", "longitude", "degrees_east" )  ; 2.5E->357.5E
   XT42     = area_conserve_remap_Wrap (x&lon, x&lat, x ,LONT42, LATT42, opt)

   printVarSummary(XT85)
   printMinMax(XT85, True)

   printVarSummary(XT42)
   printMinMax(XT42, True)

;*************************************************************
; For illustration, compute the global means of input and output grids
;*************************************************************
   NLATT159 = dimsizes(x&lat)
   gwi      = latGauWgt(NLATT159, "lat", "gaussian weights", "")
   gwoT85   = latGauWgt(NLATT85 , "lat", "gaussian weights", "")
   gwoT42   = latGauWgt(NLATT42 , "lat", "gaussian weights", "")

   xAvgT159 = wgt_areaave (x    , gwi   , 1.0, 0) 
   xAvgT85  = wgt_areaave (XT85 , gwoT85, 1.0, 0) 
   xAvgT42  = wgt_areaave (XT42 , gwoT42, 1.0, 0) 

   xAvgDiffT85 = xAvgT85-xAvgT159
   xAvgDiffT42 = xAvgT42-xAvgT159

   print(xAvgT159+"  "+xAvgT85+"   "+xAvgT42+"   "+xAvgDiffT85+"   "+xAvgDiffT42)

   eps  = 0.001
   if (max(abs(xAvgDiffT85)).lt.eps) then
       print("area_conserve_remap: T159  => T85: SUCCESS")
   else
       print("area_conserve_remap: T159  => T85: FAIL: maxDiff ="+max(abs(xAvgDiffT85)))
   end if
   if (max(abs(xAvgDiffT42)).lt.eps) then
       print("area_conserve_remap: T159  => T42: SUCCESS")
   else
       print("area_conserve_remap: T159  => T42: FAIL: maxDiff ="+max(abs(xAvgDiffT42)))
   end if

;***************************************************************
; Create plot ? 
;***************************************************************
   if (PLOT) then
       wks    = gsn_open_wks(pltType, pltDir+pltName)
       gsn_define_colormap(wks, "amwg")  
   
       plot = new ( 3 , "graphic")
     
       res                      = True     ; plot mods desired
       res@gsnDraw              = False    ; don't draw
       res@gsnFrame             = False    ; don't advance frame
       res@gsnSpreadColors      = True     ; spread the colors
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnLinesOn            = False    ; turn of contour lines
      ;res@cnFillMode           = "CellFill"           ; Cell Mode
       res@cnFillMode           = "RasterFill"         ; Raster Mode
       res@cnLinesOn            =  False       ; Turn off contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines
       res@cnLevelSelectionMode = "ExplicitLevels"              
       res@cnLevels             = (/550, 650, 750, 800, 850, 900, 925, 950, 975, 1000, 1013/)
       res@cnMissingValFillPattern = 0         ; make 'missing' black
       res@cnMissingValFillColor   = "black"
   
       res@lbLabelBarOn         = False    ; turn off individual cb's
     
       res@mpCenterLonF         = 210.
       res@mpFillOn             = False
   
      ;res@mpShapeMode          = "FreeAspect"
      ;res@vpWidthF             = 0.8
      ;res@vpHeightF            = 0.4

       nt = 0

       res@gsnLeftString   = "T159: (256,516)"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvgT159(nt))
       plot(0) = gsn_csm_contour_map_ce(wks,x, res)

       res@gsnLeftString   = "T85: (128,256)"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvgT85(nt))
       plot(1) = gsn_csm_contour_map_ce(wks,XT85, res)

       res@gsnLeftString   = "T42: (64,128)"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvgT42(nt))
       plot(2) = gsn_csm_contour_map_ce(wks,XT42, res)
     
       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelAutoStride   = True
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
       resP@txString            = "Conservative Remap: Gaussian-to-Gaussian"
       gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
   end if    ; PLOT
  
;************************************************
; Create netCDF ? ... Only do T85
; Recommend to always create a 'time' dimension 
; Save only the interpolated CMORPH (uncomment to sabe "COMB")
;************************************************
   if (netCDF) then
   
       globeAtt              = 1
       globeAtt@title        = "GPCP: T159 interpolated to a T85 grid"    
       globeAtt@source_file  = fili
       globeAtt@creation_date= systemfunc ("date" )
     
       NCFILE = ncDir + ncFil +".nc"
       system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
           
       ncdf   = addfile(NCFILE,"c")     
       fileattdef( ncdf, globeAtt )        ; create the global [file] attributes

       filedimdef(ncdf,"time",-1,True)     ; make time and UNLIMITED dimension      
                                           ; recommended  for most applications
       ncdf->PRC = XT85

   end if    ; netCDF

end
