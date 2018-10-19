;*************************************************
; asr_1.ncl
;
; Concepts illustrated:
;   - Drawing colored lines to indicate the ASR boundaries.
;   - How to index latitude/longitude arrays at the boundaries
;   - How to change the map center longitude
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
    
;*******************************************
;read netCDF file
;*******************************************
    diri  = "./"
    fila  = "asr30km.anl.2D.20000602.nc"
    fa    = addfile(diri+fila, "r")      

    lat2d = fa->XLAT
    lon2d = fa->XLONG

    dimll = dimsizes(lat2d)
    nlat  = dimll(0)
    mlon  = dimll(1)

;*******************************************
; Create plots
;*******************************************
    pltDir  = "./"
    pltName = "asr"
    pltType = "png"                               ; send graphics to PNG file
    pltPath = pltDir+pltName

    res                     = True                ; Plot modes desired.
    res@gsnMaximize         = True                ; Maximize plot
    res@gsnPolar            = "NH"                ; specify the hemisphere
    res@gsnDraw             = False
    res@gsnFrame            = False

    res@mpFillOn            = False
   ;res@mpMinLatF           = min(lat2d)
    res@tiMainString        = "ASR Boundaries"

    respl= True                                   ; polyline resources
    respl@gsLineThicknessF = 2.0                  ; thickness of lines
    
    wks = gsn_open_wks(pltType, pltPath)  
    gsn_define_colormap(wks,"default")

  do n=0,1
     ;res@mpCenterLonF = 0.0                      ; this is the default
      if (n.eq.1) then
          res@mpCenterLonF = -90.0
      end if
    
      plot = gsn_csm_map_polar(wks,res)   
  
      respl@gsLineColor      = "red" 
      gsn_polyline(wks,plot,lon2d(:,  0   ),lat2d(:,  0   ),respl)
      respl@gsLineColor      = "blue" 
      gsn_polyline(wks,plot,lon2d(:,mlon-1),lat2d(:,mlon-1),respl)
  
      respl@gsLineColor      = "green" 
      gsn_polyline(wks,plot,lon2d(nlat-1,:),lat2d(nlat-1,:),respl)
      respl@gsLineColor      = "orange" 
      gsn_polyline(wks,plot,lon2d(  0   ,:),lat2d(  0   ,:),respl)
  
      draw(plot)
      frame(wks)
 end do
