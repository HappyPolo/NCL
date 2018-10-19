;*************************************************
; WRF: sample plot of "static" variables
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

begin
;************************************************
; open file and read in data
;************************************************
  f     = addfile ("static.wrfsi.nc", "r")
;************************************************
; Read Analysis grid average elevation
; Read non-staggard lat/lon coordinates.
; Read land/sea mask
;************************************************
  x     = f->avg(0,0,:,:)                      ; avg(record, z, y, x)
  lat2d = f->lat(0,0,:,:)
  lon2d = f->lon(0,0,:,:)
  lsMask= f->lnd(0,0,:,:)                      ; land (1) water (0) mask

;************************************************
; Associate 2D coordinates with x for plotting
;************************************************
  x@lat2d = lat2d
  x@lon2d = lon2d

;************************************************
; Use mask function to set all ocean areas to _FillValue
;************************************************
  x     = mask(x,lsMask,1)
;************************************************     
; The file should be examined via: ncdump -v grid_type static.wrsi 
; This will print the print type. then enter below.               
;************************************************  
  projection = "mercator"   
;************************************************
; create plots  
;************************************************
  wks = gsn_open_wks("ps"  ,"WRF_static")     ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; select color map

  res                       = True             ; plot mods desired
  res@gsnMaximize           = True             ; uncomment to maximize size
  res@gsnSpreadColors       = True             ; use full range of colormap
  res@cnFillOn              = True             ; color plot desired
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels
  res@cnFillMode            = "RasterFill"     ; Use Raster Mode

;************************************************
; Turn on lat / lon labeling
;************************************************
  res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks

;************************************************
; set map limits
;************************************************
  dimll = dimsizes(lat2d)
  nlat  = dimll(0)
  mlon  = dimll(1)

  res@mpProjection          = projection
  res@mpLimitMode           = "Corners"  
  res@mpLeftCornerLatF      = lat2d(0,0)
  res@mpLeftCornerLonF      = lon2d(0,0)
  res@mpRightCornerLatF     = lat2d(nlat-1,mlon-1)
  res@mpRightCornerLonF     = lon2d(nlat-1,mlon-1)

  res@mpCenterLonF          = f->LoV          ; set center logitude         
                                    
  if (projection.eq."LambertConformal") then      
      res@mpLambertParallel1F   = f->Latin1      
      res@mpLambertParallel2F   = f->Latin2     
      res@mpLambertMeridianF    = f->LoV       
  end if  

  res@mpFillOn              = False            ; turn off map fill
  res@mpOutlineDrawOrder    = "PostDraw"       ; draw continental outline last
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries

;;res@tfDoNDCOverlay        = True             ; True only for 'native' grid
  res@gsnAddCyclic          = False            ; data are not cyclic
  res@lbLabelAutoStride     = True             ; let NCL determine label bar spacing

  plot                      = gsn_csm_contour_map(wks, x, res)
end
