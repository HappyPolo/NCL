;*************************************************************
; regrid_9.ncl
;
; Concepts illustrated:
;   - Reading a variable off a file and updating its meta data
;   - Interpolating from a global GAUSSIAN grid to a lower resolution
;   - Computing global areal mean values after computing the appropriate weights 
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
  ncFil   = "GPCP_2x2"
;*************************************************************
; read 
;*************************************************************
   diri  = "/Users/shea/Data/netCDF/"
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

   NLAT2x2  =   90                              ; RES   = "2x2"    
   MLON2x2  =  180                              
   LAT2x2   = latGlobeFo(NLAT2x2, "LAT", "latitude" , "degrees_north")
   LON2x2   = lonGlobeFo(MLON2x2, "LON", "longitude", "degrees_east" )  ; 1.0E->359.0E
   X2x2     = area_conserve_remap_Wrap (x&lon, x&lat, x ,LON2x2, LAT2x2, opt)
;  ---
   NLAT3x5  =  60                               ; RES   = "3x5"    
   MLON3x5  =  72                              
   LAT3x5   = latGlobeFo(NLAT3x5, "LAT", "latitude" , "degrees_north")
   LON3x5   = lonGlobeFo(MLON3x5, "LON", "longitude", "degrees_east" )  
   X3x5     = area_conserve_remap_Wrap (x&lon, x&lat, x ,LON3x5, LAT3x5, opt)

   printVarSummary(X2x2)
   printMinMax(X2x2, True)

   printVarSummary(X3x5)
   printMinMax(X3x5, True)

;*************************************************************
; For illustration, compute the global means of input and output grids
;*************************************************************
   NLATT159 = dimsizes(x&lat)
   gwi      = latGauWgt(NLATT159, "lat", "gaussian weights", "")
   gwo2x2   = latRegWgt(LAT2x2, "double", 0)
   gwo3x5   = latRegWgt(LAT3x5 ,"double", 0)

   xAvgT159 = wgt_areaave (x    , gwi   , 1.0, 0) 
   xAvg2x2  = wgt_areaave (X2x2 , gwo2x2, 1.0, 0) 
   xAvg3x5  = wgt_areaave (X3x5 , gwo3x5, 1.0, 0) 

   xAvgDiff2x2 = xAvg2x2-xAvgT159
   xAvgDiff3x5 = xAvg3x5-xAvgT159

  ;print(xAvgT159+"  "+xAvg2x2+"   "+xAvg3x5+"   "+xAvgDiff2x2+"   "+xAvgDiff3x5)

   eps  = 0.001
   if (max(abs(xAvgDiff2x2)).lt.eps) then
       print("area_conserve_remap: T159  => 2x2: SUCCESS")
   else
       print("area_conserve_remap: T159  => 2x2: FAIL: maxDiff ="+max(abs(xAvgDiff2x2)))
   end if
   if (max(abs(xAvgDiff3x5)).lt.eps) then
       print("area_conserve_remap: T159  => 3x5: SUCCESS")
   else
       print("area_conserve_remap: T159  => 3x5: FAIL: maxDiff ="+max(abs(xAvgDiff3x5)))
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
     
       res@mpCenterLonF         = 210.     ; chage to 210
       res@mpFillOn             = False
   
       nt = 0

       res@gsnLeftString   = "T159: (256,516)"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvgT159(nt))
       plot(0) = gsn_csm_contour_map_ce(wks,x, res)

       res@gsnLeftString   = "2x2: (90,180)"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvg2x2(nt))
       plot(1) = gsn_csm_contour_map_ce(wks,X2x2, res)

       res@gsnLeftString   = "3x5: (60,72)"
       res@gsnCenterString = "Areal Mean="+sprintf("%6.5f", xAvg3x5(nt))
       plot(2) = gsn_csm_contour_map_ce(wks,X3x5, res)
     
       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelAutoStride   = True
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
       resP@txString            = "Conservative Remap: Gaussian-to-Fixed"
       gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
   end if    ; PLOT
  
;************************************************
; Create netCDF ? ... Only do 2x2
; Recommend to always create a 'time' dimension 
; Save only the interpolated CMORPH (uncomment to sabe "COMB")
;************************************************
   if (netCDF) then
   
       globeAtt              = 1
       globeAtt@title        = "GPCP: T159 interpolated to a 2x2 grid"    
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
