;*************************************************************
; regrid_11.ncl
;
; Concepts illustrated:
;   - Interpolating from a fixed grid to a lower resolution gaussian grid
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
  ncFil   = "TRMM_T85"
;*************************************************************
; read
;*************************************************************

   diri  = "/Users/shea/Data/TRMM/"
   fili  = "TEST.TRMM_3B43V6_CLM.1998-2005.nc"       ; 0.25 spacing
   f     = addfile(diri+fili, "r")
   x     = f->TRMM_PRC            ; (time,lat,lon) => (1,480,1440)

   x     = x/3

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

   NLATT85    = 128                               ; RES   = "T85"    
   MLONT85    = 256                              
   LATT85     = latGau    (NLATT85, "LATT85", "latitude" , "degrees_north")  
   LONT85     = lonGlobeFo(MLONT85, "LONT85", "longitude", "degrees_east" ) 

   opt@NLATi  = nlati 
   opt@NLATo  = 128      
   LAT_REGT85 = LATT85({latS:latN})
   XT85       = area_conserve_remap_Wrap (x&lon, x&lat, x ,LONT85, LAT_REGT85, opt)
;  ---
   NLATT42=  64                               ; RES   = "T42"    
   MLONT42= 128                              
   LATT42 = latGau    (NLATT42, "LATT42", "latitude" , "degrees_north")  
   LONT42 = lonGlobeFo(MLONT42, "LONT42", "longitude", "degrees_east" )  

   opt@NLATo = NLATT42
   LAT_REGT42= LATT42({latS:latN})
   XT42   = area_conserve_remap_Wrap (x&lon, x&lat, x ,LONT42, LAT_REGT42, opt)

   printVarSummary(XT85)
   printMinMax(XT85, True)

   printVarSummary(XT42)
   printMinMax(XT42, True)

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
      ;res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day"
       res@cnLevels             = (/0.1,1,2.5,5.0,7.5,10,15,20,25,50/) ; "mm/day"
       res@cnMissingValFillPattern = 0         ; make 'missing' black
       res@cnMissingValFillColor   = "black"
   
       res@lbLabelBarOn         = False    ; turn off individual cb's
     
       res@mpCenterLonF         = 210.
       res@mpFillOn             = False
       res@mpMinLatF            = latS     ; range to zoom in on
       res@mpMaxLatF            = latN
   
       nt = 0

       res@gsnLeftString   = "0.25x0.25"
       plot(0) = gsn_csm_contour_map_ce(wks,x(nt,:,:), res)

       res@gsnLeftString   = "T85"
       plot(1) = gsn_csm_contour_map_ce(wks,XT85(nt,:,:), res)

       res@gsnLeftString   = "T42"
       plot(2) = gsn_csm_contour_map_ce(wks,XT42(nt,:,:), res)
     
       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelAutoStride   = True
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
       resP@txString            = "Conservative Remap: Fixed-to-Gaussian (Region)"
       gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
   end if    ; PLOT
  
;************************************************
; Create netCDF ? ... Only do T85
; Recommend to always create a 'time' dimension 
; Save only the interpolated CMORPH (uncomment to sabe "COMB")
;************************************************
   if (netCDF) then
       nline  = inttochar(10)

       dimx   = dimsizes(XT85)
       ntim   = dimx(0)
       nlat   = dimx(1)
       mlon   = dimx(2)
   
       time   = f->time

       globeAtt              = 1
       globeAtt@title        = "GPCP: TRMM (0.25 x 0.25) interpolated to a T85 grid"    
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
