;*************************************************
; mask_7.ncl
;
; Concepts illustrated:
;   - Generating dummy data
;   - Masking out areas of a contour plot that are below a certain threshold
;   - Adding shading or color fill to areas on a contour plot with missing data
;   - Drawing a perimeter around areas on a contour plot with missing data
;   - Paneling four plots on a page
;   - Forcing paneled plots to be in "portrait" mode
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

begin
;------------------------------------------------------------
; Set up random data array, random topography array
;------------------------------------------------------------
  ny = 50
  mx = 101
  q  = generate_2d_array(20,20,-136.148,451.834,0,(/ny,mx/))
  q@_FillValue = 1e20

  ymin = 0.0
  ymax = 5000.0
  y    = fspan(ymin,ymax,ny)

  q!0  = "y" 
  q&y  =  y  

  tmax = 0.4*ymax
                           ; topography
  topog = tmax*sin(3.14159*(fspan(0,mx-1,mx)/mx))  \  ; simple
      + random_uniform(0,0.75*tmax,mx)              ; random component
  i   = ind(topog.lt.0.7*tmax)
  topog(i) = 0.0
;-----------------------------------------------------------------
; Create new q array that is masked by the topog array set up above
;-----------------------------------------------------------------
  t2d  = conform(q,topog,1) 
  h2d  = conform(q, y ,0) 

  qMask = q                      ; copy Y-Coordinate variable
  qMask = (/ mask(q,t2d.gt.h2d, False)  /)

;-----------------------------------------------------------------
; plot to compare
;-----------------------------------------------------------------  
  wks   = gsn_open_wks("png","mask")     ; send graphics to PNG file
  plot  = new(3,graphic)

  res                              = True
  res@gsnDraw                      = False  
  res@gsnFrame                     = False  

  plot(0) = gsn_csm_contour(wks,q,res)   ; plot unmasked array
	
  res@cnMissingValFillColor = "gray30"   ; fill the missing value areas with dark gray
  res@cnFillOn = True                    ; must turn on color fill to fill missing value areas
  res@cnMonoFillColor = True             ; color fill with one color
  res@cnFillColor = 0                    ; set to background
  res@cnMissingValFillPattern = 0        ; set to complete fill 
  res@lbLabelBarOn = False               ; turn off label bar
  plot(1) = gsn_csm_contour(wks,qMask,res)  ; plot masked array with missing value areas filled

  delete(res@cnMissingValFillPattern)    ; no longer filling missing value areas
  delete(res@cnMissingValFillColor)      ; no longer filling missing value areas
  res@cnFillOn = False                   ; no need to color fill to outline missing value areas
  res@cnMissingValPerimOn = True         ; turn on missing value outlines
  res@cnMissingValPerimColor = "gray30"  ; outline missing value areas with dark gray line
  res@cnMissingValPerimThicknessF = 2.5  ; set the missing value outline thickness
  plot(2) = gsn_csm_contour(wks,qMask,res)  ; plot masked array with missing value areas outlined

  resP    = True
  resP@gsnMaximize = True
  resP@gsnPaperOrientation = "portrait"
  gsn_panel(wks,plot,(/2,2/),resP)
end
