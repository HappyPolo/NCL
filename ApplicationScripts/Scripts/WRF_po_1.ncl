;*************************************************
; WRF: basic black and white contour on Lambert Conformal Map
;      at a specified time and level.
;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;************************************************************
; open file and read a variable at specified time/level
;************************************************************
  f      = addfile("wrfout_d01_2003-09-28_00:00:00.nc", "r")
  times  = chartostring(f->Times)         ; convert to type string for plot
printVarSummary(f->T)
  x      = f->T(0,8,:,:)         
;************************************************************
; The following are read to extract information
; that will be used for correct plotting and labeling
;************************************************************
  znu    = f->ZNU(0,:)                    ; (Time, bottom_top)
  lat2d  = f->XLAT(0,:,:)                 ; need for map limits        
  lon2d  = f->XLONG(0,:,:)      

  dimll  = dimsizes(lat2d)                ; get size of dimensions
  nlat   = dimll(0)
  mlon   = dimll(1)
;************************************************
; create plots  
;************************************************
  wks = gsn_open_wks("ps"  ,"WRF_po")     ; ps,pdf,x11,ncgm,eps
  res                       = True        ; plot mods desired
;;res@gsnMaximize           = True        ; uncomment to maximize size
  res@cnLineThicknessF      = 2.0         ; make twice as thick as default
  res@cnLineLabelBackgroundColor = "background" ; no lines through labels

;************************************************
; The following illustrates the required resource
; setting for native Mercator Mapping 
;************************************************
; Subsequent examples will use a simple function
;         WRF_map_c (f, res, 0)
; located in WRF_contributed.ncl that will test 
; for the "MAP_PROJ" attribute. It will set the 
; appropriate resources. 
;************************************************
  res@gsnAddCyclic          = False       ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True        ; set True for native projection

  res@mpProjection          = "Stereographic"
  res@mpLimitMode           = "Corners"  
  res@mpLeftCornerLatF      = lat2d(0,0)
  res@mpLeftCornerLonF      = lon2d(0,0)
  res@mpRightCornerLatF     = lat2d(nlat-1,mlon-1)
  res@mpRightCornerLonF     = lon2d(nlat-1,mlon-1)
  res@mpCenterLonF          = f@CEN_LON
;  res@mpCenterLatF          = f@CEN_LAT
  res@mpCenterLatF          = 90.         ; This is necessary to fix the wrong value on the WRF file.

  res@mpOutlineDrawOrder    = "PostDraw"  ; draw continental outline last
  res@mpFillDrawOrder       = "PreDraw"
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries
  res@mpFillOn              = False       ; turn off map fill
;************************************************
; establish title 
;************************************************
  res@tiMainString          = times(0)+"  z="+znu(8)
  plot                      = gsn_csm_contour_map(wks, x, res)
end

