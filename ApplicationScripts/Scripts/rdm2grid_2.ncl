;*************************************************
; rdm2grid_2.ncl
;*************************************************
;
; Concepts illustrated:
;   - Reading SLP from netCDF
;   - Using array syntax[ ::-1 ] so that lat is South-to-North
;   - Generating random index values for demo
;   - Using grid2triple to interpolate from a grid to triples
;   - Plotting original and reconstructed grids
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  NOBS  = 500      

;------------------------------------------------------------------
; Read data
;------------------------------------------------------------------

  diri = "./"  
  fili = "slp_1988mm.nc"
  f    = addfile(diri+fili, "r")
  Z    = f->slp(0,::-1,:)

;------------------------------------------------------------------
; Generate N random values from the above
;------------------------------------------------------------------

  dimz  = dimsizes( Z )
  nlat  = dimz(0)
  mlon  = dimz(1)

  N     = nlat*mlon
  iZ    = generate_unique_indices( N )
 ;iZ    = floattoint(random_uniform (0, N-1, N))  
  trip  = grid2triple (Z&lon, Z&lat, Z) 

  dlon  = Z&lon(2)-Z&lon(1)
  reps  = random_uniform (-dlon, dlon, N)  ; minor location perturbations

  IOBS  = iZ(0:NOBS)   ; convenience
                       ; clarity only ... create explicit variables  
  rlon  = trip(0,IOBS) + reps(IOBS)  
  rlat  = trip(1,IOBS) + reps(IOBS(::-1))
  rZ    = trip(2,IOBS)

  rlon@units = "degrees_east"
  rlat@units = "degrees_north"

;------------------------------------------------------------------
; cssgrid
;------------------------------------------------------------------
  zcss  = cssgrid_Wrap (rlat, rlon, rZ, Z&lat,Z&lon)

;------------------------------------------------------------------
; plot
;------------------------------------------------------------------
  maxLev   = 16
  mnmxint  = nice_mnmxintvl( min(zcss), max(zcss), maxLev, True)

  dimzcss  = dimsizes(zcss)
  kplt     = dimzcss(0)

  wks      = gsn_open_wks("png","rdm2grid") ; send graphics to PNG file
  plot     = new(2,graphic)           
  
  res                     = True
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnFillOn            = True            ; turn on color
  res@cnFillPalette       = "amwg"          ; set color map
 ;res@cnLinesOn           = False           ; turn off contour lines
  res@cnLineLabelsOn      = False           ; turn off contour line labels
  res@lbLabelBarOn        = False           ; turn off individual cb's
  res@mpCenterLonF        = 180.

  res@cnLevelSelectionMode =  "ManualLevels"   
  res@cnMinLevelValF       = mnmxint(0) 
  res@cnMaxLevelValF       = mnmxint(1) 
  res@cnLevelSpacingF      = mnmxint(2) 

  pmres = True
  pmres@gsMarkerIndex      = 16             ; Filled circle
  pmres@gsMarkerSizeF      = 0.0125

  res@gsnCenterString = "Original grid"
  plot(0) = gsn_csm_contour_map(wks,Z,res) 
   
  res@gsnCenterString = "CSSGRID: N="+NOBS
  plot(1) = gsn_csm_contour_map(wks,zcss,res) 
          ; add polymarkers
  dum1    = gsn_add_polymarker(wks, plot(1), rlon, rlat, pmres)
 
;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
 ;resP@txString            = title
  resP@gsnMaximize         = True                ; make large
  resP@gsnPanelLabelBar    = True                ; add common colorbar
 ;resP@lbLabelStride       = 2                   ; force every other label 
 ;resP@lbLabelFontHeightF  = 0.0125              ; make labels smaller [0.2 default]

  gsn_panel(wks,plot,(/2,1/),resP)            ; now draw as one plot
end

