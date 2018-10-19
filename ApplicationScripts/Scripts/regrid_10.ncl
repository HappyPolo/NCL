;*************************************************************
; regrid_10.ncl
;
; Concepts illustrated:
;   - Interpolating from a fixed grid to a lower resolution fixed grid using conservative remapping
;   - Computing global areal mean values by generating the weights 
;   - Creating a color map using named colors
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
  ncFil   = "TRMM_2x2"
;*************************************************************
; read
;*************************************************************

   diri  = "/Users/shea/Data/TRMM/"
   fili  = "TEST.TRMM_3B43V6_CLM.1998-2005.nc"       ; 0.25 spacing
   f     = addfile(diri+fili, "r")
   x     = f->TRMM_PRC            ; (time,lat,lon) => (1,480,1440)

   printVarSummary(x)
   printMinMax(x, True)
;*************************************************************
; get dimension sizes and other information
;*************************************************************

   dimx  = dimsizes( x )
   ntim  = dimx( 0 )
   nlat  = dimx( 1 )                 ; 400   [0.25 x 0.25 ]
   mlon  = dimx( 2 )                 ; 1440

   latS  = x&lat(0)                  ; south extent of input grid
   latN  = x&lat(nlat-1)             ; north extent

   dimx  = dimsizes( x )
   ntim  = dimx( 0 )
   nlat  = dimx( 1 )                 ; 400   [0.25 x 0.25 ]
   mlon  = dimx( 2 )                 ; 1440

   latS  = x&lat(0)                  ; south extent of input grid
   latN  = x&lat(nlat-1)             ; north extent

   nlati = 720                       ; global extent of input grid [180/0.25]
;*************************************************************
; perform conservative remapping to two different grid resolutions
;*************************************************************

   opt = True

   NLAT2x2    =  90                               ; RES   = "2x2"    
   MLON2x2    = 180                              
   LAT2x2     = latGlobeFo(NLAT2x2, "LAT2x2", "latitude" , "degrees_north")  ; 89S -> 89N
   LON2x2     = lonGlobeFo(MLON2x2, "LON2x2", "longitude", "degrees_east" )  ; 1E->359E

   opt@NLATi  = nlati 
   opt@NLATo  = NLAT2x2
   LAT_REG2x2 = LAT2x2({latS:latN})
   X2x2       = area_conserve_remap_Wrap (x&lon, x&lat, x ,LON2x2, LAT_REG2x2, opt)
;  ---
   NLAT4x5=  45                               ; RES   = "4x5"    
   MLON4x5=  72                              
   LAT4x5 = latGlobeFo(NLAT4x5, "LAT4x5", "latitude" , "degrees_north")  
   LON4x5 = lonGlobeFo(MLON4x5, "LON4x5", "longitude", "degrees_east" )  ; 2.5E->357.5E

   opt@NLATo = NLAT4x5
   LAT_REG4x5= LAT4x5({latS:latN})
   X4x5   = area_conserve_remap_Wrap (x&lon, x&lat, x ,LON4x5, LAT_REG4x5, opt)

   printVarSummary(X2x2)
   printMinMax(X2x2, True)

   printVarSummary(X4x5)
   printMinMax(X4x5, True)

;*************************************************************
; For illustration, compute the global means of input and output grids
; This can be a bit confusing.
;*************************************************************
   lat_TRMM_Globe = latGlobeFo(nlati, "lat_TRMM_Globe", "latitude" , "degrees_north")  

   gwi     = latRegWgt(lat_TRMM_Globe, "double", 0)  ; input lat weights
   gwo2x2  = latRegWgt(LAT2x2 , "double", 0)           ; output lat weights 2x2
   gwo4x5  = latRegWgt(LAT4x5 , "double", 0)           ; output lat weights 4x5

   xAvg    = wgt_areaave (x   , gwi({latS:latN})   , 1.0, 0) 
   xAvg2x2 = wgt_areaave (X2x2, gwo2x2({latS:latN}), 1.0, 0) 
   xAvg4x5 = wgt_areaave (X4x5, gwo4x5({latS:latN}), 1.0, 0) 

   xAvgDiff2x2 = xAvg2x2-xAvg
   xAvgDiff4x5 = xAvg4x5-xAvg

   print(xAvg+"  "+xAvg2x2+"   "+xAvg4x5+"   "+xAvgDiff2x2+"   "+xAvgDiff4x5)

   eps  = 0.001
   if (max(abs(xAvgDiff2x2)).lt.eps) then
       print("area_conserve_remap: 1x1  => 2x2: SUCCESS")
   else
       print("area_conserve_remap: 1x1  => 2x2: FAIL: maxDiff ="+max(abs(xAvgDiff2x2)))
   end if
   if (max(abs(xAvgDiff4x5)).lt.eps) then
       print("area_conserve_remap: 1x1  => 4x5: SUCCESS")
   else
       print("area_conserve_remap: 1x1  => 4x5: FAIL: maxDiff ="+max(abs(xAvgDiff4x5)))
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
       res@mpMinLatF            = latS     ; range to zoom in on
       res@mpMaxLatF            = latN
   
       nt = 0

       res@gsnLeftString   = "0.25x0.25"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvg(nt))
       plot(0) = gsn_csm_contour_map_ce(wks,x(nt,:,:), res)

       res@gsnLeftString   = "2x2"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvg2x2(nt))
       plot(1) = gsn_csm_contour_map_ce(wks,X2x2(nt,:,:), res)

       res@gsnLeftString   = "4x5"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvg4x5(nt))
       plot(2) = gsn_csm_contour_map_ce(wks,X4x5(nt,:,:), res)
     
       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelAutoStride   = True
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
       resP@txString            = "Conservative Remap: Fixed-to-Fixed (Region)"
       gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
   end if    ; PLOT
  
;************************************************
; Create netCDF ? ... Only do 2x2
; Recommend to always create a 'time' dimension 
; Save only the interpolated TRMM 
;************************************************
   if (netCDF) then
       nline  = inttochar(10)

       dimx   = dimsizes(X2x2)
       ntim   = dimx(0)
       nlat   = dimx(1)
       mlon   = dimx(2)
   
       time   = f->time

       globeAtt              = 1
       globeAtt@title        = "GPCP: TRMM (0.25 x 0.25) interpolated to a 2x2 grid"    
       globeAtt@source_file  = fili
       globeAtt@creation_date= systemfunc ("date" )
     
       NCFILE = ncDir + ncFil +".nc"
       system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
           
       ncdf   = addfile(NCFILE,"c")     
       fileattdef( ncdf, globeAtt )        ; create the global [file] attributes

       filedimdef(ncdf,"time",-1,True)     ; make time and UNLIMITED dimension      
                                           ; recommended  for most applications
       ncdf->PRC = X2x2
   end if    ; netCDF

end
