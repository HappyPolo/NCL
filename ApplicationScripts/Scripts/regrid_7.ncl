;*************************************************************
; regrid_7.ncl
;
; Concepts illustrated:
;   - Reading data of type "short" and converting it to float
;   - Reordering North->South data so it is South->North
;   - Interpolating from a global FIXED grid to a lower resolution
;   - Computing global areal mean values after generating the weights 
;   - Creating a color map using named colors
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Paneling three plots vertically on a page
;   - Creating a netCDF file
;   - Using "systemfunc" to execute a UNIX command
;   - Using "system" to execute a UNIX command
;   - Using "systemfunc" to get the current date
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
  ncFil   = "GPCP_T63"
;*************************************************************
; read and reorder the data
;*************************************************************
   diri   = "./"
   fili   = "pregpcp.test.daily.nc"          ; (lat, lon)  => (180,360)

   f      = addfile(diri+fili, "r")      
   x      = short2flt(f->data)               ; (time,lat,lon), original order N->S
   x      = x(:,::-1,:)                      ; Make s->N as required by "area_conserve_remap"

  ;printVarSummary(x)
  ;printMinMax(x, True)
;*************************************************************
; perform conservative remapping to two different grid resolutions
;*************************************************************
   opt    = False

   NLATT63=  96                               ; RES   = "T63"    
   MLONT63= 2*NLATT63                        
   LATT63 = latGau   (NLATT63, "LAT", "latitude" , "degrees_north")  ;            
   LONT63 = lonGlobeF(MLONT63, "LON", "longitude", "degrees_east" )  ; 1.5E->358.5E
   XT63   = area_conserve_remap_Wrap (x&lon, x&lat, x ,LONT63, LATT63, opt)
;  ---
   NLATT42=  64                               ; RES   = "T42"    
   MLONT42=  2*NLATT42                       
   LATT42 = latGau   (NLATT42, "LAT", "latitude" , "degrees_north")  ; 87S -> 87N
   LONT42 = lonGlobeF(MLONT42, "LON", "longitude", "degrees_east" )  ; 2.5E->357.5E
   XT42   = area_conserve_remap_Wrap (x&lon, x&lat, x ,LONT42, LATT42, opt)

   printVarSummary(XT63)
   printMinMax(XT63, True)

   printVarSummary(XT42)
   printMinMax(XT42, True)

;*************************************************************
; For illustration, compute the global means of input and output grids
;*************************************************************
   gwi     = latRegWgt(x&lat , "double", 0)           ; input  lat weights
   gwoT63  = latGauWgt(NLATT63, "lat", "gaussian weights", "")
   gwoT42  = latGauWgt(NLATT42, "lat", "gaussian weights", "")

   xAvg1x1 = wgt_areaave (x   , gwi   , 1.0, 0) 
   xAvgT63 = wgt_areaave (XT63, gwoT63, 1.0, 0) 
   xAvgT42 = wgt_areaave (XT42, gwoT42, 1.0, 0) 

   xAvgDiffT63 = xAvgT63-xAvg1x1
   xAvgDiffT42 = xAvgT42-xAvg1x1

   print(xAvg1x1+"  "+xAvgT63+"   "+xAvgT42+"   "+xAvgDiffT63+"   "+xAvgDiffT42)

   eps  = 0.001
   if (max(abs(xAvgDiffT63)).lt.eps) then
       print("area_conserve_remap: 1x1  => T63: SUCCESS")
   else
       print("area_conserve_remap: 1x1  => T63: FAIL: maxDiff ="+max(abs(xAvgDiffT63)))
   end if
   if (max(abs(xAvgDiffT42)).lt.eps) then
       print("area_conserve_remap: 1x1  => T42: SUCCESS")
   else
       print("area_conserve_remap: 1x1  => T42: FAIL: maxDiff ="+max(abs(xAvgDiffT42)))
   end if

;***************************************************************
; Create plot ? 
;***************************************************************
   if (PLOT) then
       wks    = gsn_open_wks(pltType, pltDir+pltName)
       colors = (/"white","black","Snow"     \ ; "WhiteSmoke"  \
               ,"PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
               ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)
       gsn_define_colormap(wks, colors)               ; generate new color map
   
       plot = new ( 3 , "graphic")
     
       res                      = True     ; plot mods desired
       res@gsnDraw              = False    ; don't draw
       res@gsnFrame             = False    ; don't advance frame
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnLinesOn            = False    ; turn of contour lines
      ;res@cnFillMode           = "CellFill"           ; Cell Mode
       res@cnFillMode           = "RasterFill"         ; Raster Mode
       res@cnLinesOn            =  False       ; Turn off contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines
       res@cnLevelSelectionMode = "ExplicitLevels"              
       res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day"
       res@cnMissingValFillPattern = 0         ; make 'missing' black
       res@cnMissingValFillColor   = "black"
   
       res@lbLabelBarOn         = False    ; turn off individual cb's
     
       res@mpCenterLonF         = 210.
       res@mpFillOn             = False
   
      ;res@mpShapeMode          = "FreeAspect"
      ;res@vpWidthF             = 0.8
      ;res@vpHeightF            = 0.4

       nt = 0

       res@gsnLeftString   = "1x1"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvg1x1(nt))
       plot(0) = gsn_csm_contour_map_ce(wks,x(nt,:,:), res)

       res@gsnLeftString   = "T63"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvgT63(nt))
       plot(1) = gsn_csm_contour_map_ce(wks,XT63(nt,:,:), res)

       res@gsnLeftString   = "T42"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvgT42(nt))
       plot(2) = gsn_csm_contour_map_ce(wks,XT42(nt,:,:), res)
     
       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelAutoStride   = True
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
       resP@txString            = "Conservative Remap: Fixed-to-Gaussian"
       gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
   end if    ; PLOT
  
;************************************************
; Create netCDF ? ... Only do T63
; Recommend to always create a 'time' dimension 
; Save only the interpolated CMORPH (uncomment to sabe "COMB")
;************************************************
   if (netCDF) then
       nline  = inttochar(10)

       dimx   = dimsizes(XT63)
       ntim   = dimx(0)
       nlat   = dimx(1)
       mlon   = dimx(2)
   
       time   = f->time

       globeAtt              = 1
       globeAtt@title        = "GPCP: 1x1 interpolated to a T63 grid"    
       globeAtt@source_file  = fili
       globeAtt@creation_date= systemfunc ("date" )
     
       NCFILE = ncDir + ncFil +".nc"
       system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
           
       ncdf   = addfile(NCFILE,"c")     
       fileattdef( ncdf, globeAtt )        ; create the global [file] attributes

       filedimdef(ncdf,"time",-1,True)     ; make time and UNLIMITED dimension      
                                           ; recommended  for most applications
       ncdf->PRC = XT63

   end if    ; netCDF

end
