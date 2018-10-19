;***********************************************
; popmask_1.ncl
;
; Concepts illustrated:
;   - Creating contours of POP Basin index values
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
begin
  diri      = "./"
  fili      = "gx1v6_ocn.nc"
  f         = addfile (diri+fili, "r")

  x        = f->REGION_MASK
 ;printVarSummary(x)
 ;printMinMax(x, True)     ; ==>  -14 to 11

  x@lat2d   = f->TLAT
  x@lon2d   = f->TLONG

;=================================================;
; Not needed for graphics
; **For fun** print out the number of grid points in each region
;=================================================;
  printVarSummary(x)
  printMinMax(x, True)              ; -14 ==> 11

  do REGION=min(x),max(x)
     n = num(x.eq.REGION)
     print("REGION="+REGION+"   n="+n)
  end do

;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("ps","popmask")  
  gsn_define_colormap(wks, "amwg")  

  res                  = True                ; plot mods desired
  res@gsnMaximize      = True 
  res@gsnAddCyclic     = True 

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        =  False             ; Turn off contour lines

  res@cnLevelSelectionMode = "ExplicitLevels" 
  res@cnLevels         =   (/ -13,-12,-5,0,1,2,3,4,5,6,7,8,9,10,11/)

  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
 ;res@lbLabelStrings   = ""+ res@cnLevels   ; trick 
  res@lbLabelStrings   = ""+ (/ -14,-13,-12,-5,0,1,2,3,4,5,6,7,8,9,10,11/)

  res@pmLabelBarHeightF=  0.100
  res@pmLabelBarWidthF =  0.80              ; default is 0.6

  res@mpCenterLonF     = 205                ; set map center
  res@mpFillOn         = False

  res@tiMainString     = "POP: Basin Index Values"
  res@gsnLeftString    = "Selected Basins"        
  res@gsnRightString   = fili
  plot = gsn_csm_contour_map_ce(wks, x, res) ; create plot
end
