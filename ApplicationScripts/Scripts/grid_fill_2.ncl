;*************************************************
; grid_fill_2.ncl
;*************************************************
;
; Concepts illustrated:
;   - Reading a NetCDF file
;   - Setting parameters for "poisson_grid_fill"
;   - Illustrating before and after application of poisson_grid_fill
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
                                   
  dir   = "./"
  fil   = "HADLEY_SSTCLM.1971-2000.nc"
  f     = addfile (dir+fil , "r")
  x     = f->SST_CLM(0,:,:)        ; (month,lat,lon) => (12,180,260)
  printVarSummary(x)

  xOrig = x                        ; save original grid for later plot
;-----------------------------------------------------------------
; Set the poisson_grid_fill variables
; Global grid: Fill in over land             
;-----------------------------------------------------------------
  nscan = 2000             ; usually *much* fewer
  eps   = 0.001            ; variable depended
  gtype = True             ; Cyclic in longitude [global]
  guess = 0                ; use zonal means
  relc  = 0.6              ; standard relaxation coef
  opt   = 0

  poisson_grid_fill( x, gtype, guess, nscan, eps, relc, opt)

;-----------------------------------------------------------------
; Regional grid: interpolation and extrapolation         
;-----------------------------------------------------------------
  latS = -55
  latN =  0 
  lonL = -60
  lonR = -10
  y    = f->SST_CLM(0,{latS:latN},{lonL:lonR})  

  yOrig= y

  gtype = False            ; regional ... not cyclic in lon
  poisson_grid_fill( y, gtype, guess, nscan, eps, relc, opt)

;-----------------------------------------------------------------
; plot for compare
;-----------------------------------------------------------------
  
  wks   = gsn_open_wks("png","grid_fill")       ; send graphics to PNG file
  plot  = new(2,graphic)     

  res                              = True
  res@gsnDraw                      = False  
  res@gsnFrame                     = False  
  res@cnInfoLabelOrthogonalPosF    = -0.07  

  resP    = True
 ;resP@txString            = title
  resP@gsnMaximize         = True               ; make large
  resP@gsnPanelLabelBar    = True               ; add common colorbar
 ;resP@lbLabelStride       = 2                  ; force every other label 
 ;resP@lbLabelFontHeightF  = 0.0125             ; make labels smaller [0.2 default]


; Global

  res@gsnRightString = "Original"
  plot(0) = gsn_csm_contour_map_ce(wks,xOrig,res)           

  res@gsnRightString = "poisson_grid_fill"
  plot(1) = gsn_csm_contour_map_ce(wks,x    ,res)           
  gsn_panel(wks,plot,(/2,1/),resP)

; Regional

  res@gsnAddCyclic         = False 
  res@mpMinLatF            = latS
  res@mpMaxLatF            = latN
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR

  res@gsnRightString = "Original"
  plot(0) = gsn_csm_contour_map(wks,yOrig,res)           

  res@gsnRightString = "poisson_grid_fill"
  plot(1) = gsn_csm_contour_map(wks,y    ,res)           
  gsn_panel(wks,plot,(/2,1/),resP)

end
