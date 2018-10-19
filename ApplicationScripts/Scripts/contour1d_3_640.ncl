;*************************************************
; contour1d_3_640.ncl           
;
; This script is identical to contour1d_3.ncl,
; except it uses the special lat1d/lon1d
; attributes added in V6.4.0 for contouring.
;*************************************************
; Concepts illustrated:
;   - Contouring one-dimensional X, Y, Z data
;   - Using the special "lat1d" / "lon1d" attributes for plotting
;   - Generating random index values for demo
;   - Using grid2triple to interpolate from a grid to triples
;   - Plotting original and reconstructed grids
;======================================================================
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
  Z    = f->slp(0,:,:)            

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
  rZ       = trip(2,IOBS)
  rZ@lon1d = trip(0,IOBS) + reps(IOBS)           ; Recognition of the lat1d/lon1d attributes
  rZ@lat1d = trip(1,IOBS) + reps(IOBS(::-1))     ; were added in NCL V6.4.0

;------------------------------------------------------------------
; plot
;------------------------------------------------------------------
  maxLev   = 16
  mnmxint  = nice_mnmxintvl( min(Z), max(Z), maxLev, True)

  wks      = gsn_open_wks("png","contour1d")        ; send graphics to PNG file       
  plot     = new(2,graphic)           
  
  res                     = True
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnFillOn            = True            ; turn on color
  res@cnFillPalette       = "amwg"          ; set color map
 ;res@cnLinesOn           = False           ; turn off contour lines
 ;res@cnLineLabelsOn      = False           ; turn off contour line labels

  res@lbLabelBarOn        = False           ; turn off individual cb's
  res@mpCenterLonF        = 180.

  res@cnLevelSelectionMode =  "ManualLevels"   
  res@cnMinLevelValF       = mnmxint(0) 
  res@cnMaxLevelValF       = mnmxint(1) 
  res@cnLevelSpacingF      = mnmxint(2) 

  pmres = True
  pmres@gsMarkerIndex      = 16             ; Filled circle
  pmres@gsMarkerSizeF      = 0.0125
  pmres@gsnCoordsAttach    = True

  res@gsnCenterString = "Original grid"
  plot(0) = gsn_csm_contour_map_ce(wks,Z,res) 
   
  res@gsnCenterString = "Triangular Mesh: N="+NOBS
  plot(1) = gsn_csm_contour_map_ce(wks,rZ,res) 
  gsn_coordinates(wks,plot(1),rZ,pmres)    ; add markers at lat/lon locations
 
;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
 ;resP@txString            = title
  resP@gsnMaximize         = True                ; make large
  resP@gsnPanelLabelBar    = True                ; add common colorbar
 ;resP@lbLabelStride       = 2                   ; force every other label 
 ;resP@lbLabelFontHeightF  = 0.0125              ; make labels smaller [0.2 default]

  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
end

