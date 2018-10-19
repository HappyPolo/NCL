;*************************************************************
; regrid_6.ncl
;
; Concepts illustrated:
;   - Reading data of type "short" and converting it to float
;   - Reordering North->South data so it is South->North
;   - Interpolating from a fixed grid to a lower resolution grid using conservative remapping
;   - Computing global areal mean values by generating the weights 
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
  ncFil   = "GPCP_2x3"
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

   NLAT2x3=  90                               ; RES   = "2x3"    
   MLON2x3= 120                              
   LAT2x3 = latGlobeFo(NLAT2x3, "LAT", "latitude" , "degrees_north")  ; 89S -> 89N
   LON2x3 = lonGlobeFo(MLON2x3, "LON", "longitude", "degrees_east" )  ; 1.5E->358.5E
   X2x3   = area_conserve_remap_Wrap (x&lon, x&lat, x ,LON2x3, LAT2x3, opt)
;  ---
   NLAT5x5=  36                               ; RES   = "5x5"    
   MLON5x5=  72                              
   LAT5x5 = latGlobeFo(NLAT5x5, "LAT", "latitude" , "degrees_north")  ; 87.5S -> 87.5N
   LON5x5 = lonGlobeFo(MLON5x5, "LON", "longitude", "degrees_east" )  ; 2.5E->357.5E
   X5x5   = area_conserve_remap_Wrap (x&lon, x&lat, x ,LON5x5, LAT5x5, opt)

   printVarSummary(X2x3)
   printMinMax(X2x3, True)

   printVarSummary(X5x5)
   printMinMax(X5x5, True)

;*************************************************************
; For illustration, compute the global means of input and output grids
;*************************************************************
   gwi     = latRegWgt(x&lat , "double", 0)           ; input  lat weights
   gwo2x3  = latRegWgt(LAT2x3, "double", 0)           ; output lat weights 2x3
   gwo5x5  = latRegWgt(LAT5x5, "double", 0)           ; output lat weights 5x5

   xAvg1x1 = wgt_areaave (x   , gwi   , 1.0, 0) 
   xAvg2x3 = wgt_areaave (X2x3, gwo2x3, 1.0, 0) 
   xAvg5x5 = wgt_areaave (X5x5, gwo5x5, 1.0, 0) 

   xAvgDiff2x3 = xAvg2x3-xAvg1x1
   xAvgDiff5x5 = xAvg5x5-xAvg1x1

   print(xAvg1x1+"  "+xAvg2x3+"   "+xAvg5x5+"   "+xAvgDiff2x3+"   "+xAvgDiff5x5)

   eps  = 0.001
   if (max(abs(xAvgDiff2x3)).lt.eps) then
       print("area_conserve_remap: 1x1  => 2x3: SUCCESS")
   else
       print("area_conserve_remap: 1x1  => 2x3: FAIL: maxDiff ="+max(abs(xAvgDiff2x3)))
   end if
   if (max(abs(xAvgDiff5x5)).lt.eps) then
       print("area_conserve_remap: 1x1  => 5x5: SUCCESS")
   else
       print("area_conserve_remap: 1x1  => 5x5: FAIL: maxDiff ="+max(abs(xAvgDiff5x5)))
   end if

;***************************************************************
; Create plot  
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

       res@gsnLeftString   = "2x3"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvg2x3(nt))
       plot(1) = gsn_csm_contour_map_ce(wks,X2x3(nt,:,:), res)

       res@gsnLeftString   = "5x5"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvg5x5(nt))
       plot(2) = gsn_csm_contour_map_ce(wks,X5x5(nt,:,:), res)
     
       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelAutoStride   = True
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
       resP@txString            = "Conservative Remap: Fixed-to-Fixed"
       gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
   end if    ; PLOT
  
;************************************************
; Create netCDF ? ... Only do 2x3
; Recommend to always create a 'time' dimension 
; Save only the interpolated CMORPH (uncomment to sabe "COMB")
;************************************************
   if (netCDF) then
       nline  = inttochar(10)

       dimx   = dimsizes(X2x3)
       ntim   = dimx(0)
       nlat   = dimx(1)
       mlon   = dimx(2)
   
       time   = f->time

       globeAtt              = 1
       globeAtt@title        = "GPCP: 1x1 interpolated to a 2x3 grid"    
       globeAtt@source_file  = fili
       globeAtt@creation_date= systemfunc ("date" )
     
       NCFILE = ncDir + ncFil +".nc"
       system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
           
       ncdf   = addfile(NCFILE,"c")     
       fileattdef( ncdf, globeAtt )        ; create the global [file] attributes

       filedimdef(ncdf,"time",-1,True)     ; make time and UNLIMITED dimension      
                                           ; recommended  for most applications
       ncdf->PRC = X2x3

   end if    ; netCDF

end
