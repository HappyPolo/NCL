;***********************************************
; popmask_2.ncl
;
; Concepts illustrated:
;   - Using a region mask to plot only the Atlantic basic
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
begin
  diri      = "./"
  fili      = "gx1v6_ocn.nc"
  f         = addfile(diri+fili,"r")

  rmask     = f->REGION_MASK

;=================================================;
; Not needed for graphics
; **For fun** print out the number of grid points in each region
;=================================================;
  printVarSummary(rmask)
  printMinMax(rmask, True)       ; -14 ==> 11

  do REGION=-14,11
     n = num(rmask.eq.REGION)
     print("REGION="+REGION+"   n="+n)
  end do

;=================================================;
; Mask out all regions but REGION 6 [Atlantic]
;=================================================;
  x         = f->TEMP(0,0,:,:)      ; x(nlat,mlon) 

  REGION    = 6                     ; Atlantic
  x         = mask(x, rmask.ne.REGION, False) 

  x@lat2d   = f->TLAT
  x@lon2d   = f->TLONG

;=================================================;
; Create plot: Zoom in on the region
;=================================================;
  wks  = gsn_open_wks("x11","popmask")            ; open a ps file
  gsn_define_colormap(wks,"amwg")                ; choose colormap
  i = NhlNewColor(wks,0.8,0.8,0.8)               ; add gray to colormap

  res                      = True
  res@gsnMaximize          = True                 ; make pe, eps, pdf large
  res@cnFillOn             = True                 ; turn on color
  res@cnFillMode           = "RasterFill"         ; turn on raster mode
  res@cnLinesOn            = False                ; turn off contour lines
  res@lbLabelAutoStride    = True                 ; let NCL decide spacing
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorEnd    = -2                   ; don't use gray for contours
  res@gsnAddCyclic         = True                 ; force cyclic value
  res@mpFillDrawOrder      = "PostDraw"           ; color of land
  res@mpLandFillColor      = "grey"               ; color of land

  res@mpMinLatF            = -37.5                ; range to zoom in on
  res@mpMaxLatF            =  70.
  res@mpMinLonF            =-102.5
  res@mpMaxLonF            =  20.

  plot = gsn_csm_contour_map_ce(wks,x,res)
end
  

