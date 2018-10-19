; ***********************************************
; xy_33.ncl
;
; Concepts illustrated:
;   - Read a simple ascii file
;   - Apply running 13-point average via 'runave'
;   - Fit a 3rd degree polynomial to output from 'runave'
;   - Changing the size/shape of an XY plot using viewport resources
;   - Force explicit min & max of x-axis (abscissa)
;   - plot multiple curves using a common array
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

   y  = asciiread("expl_33.txt", -1, "float")   ; -1 means readd all rows
   ny = dimsizes(y)

   x  = ispan(1,ny,1)

;---Excel match: (a) runavg; (b) fit polynomial to runavg; (c) final curve

   nrun = 13                                     ; 13-pt running average
   yrun = runave(y, nrun, 1)                 

   np   = 3                                      ; order of polynomial
   crun = lspoly(x, yrun, 1, (np+1))             ; fit polynomial to run avg
   print(crun)
   yxcl = crun(0) + crun(1)*x + crun(2)*x^2 + crun(3)*x^3 ; generate polynomial curve

;---Start the graphics.
   wks = gsn_open_wks ("png","xy")            ; send graphics to PNG file
   gsn_define_colormap(wks,"default")

   res   = True                     ; plot mods desired
   res@gsnMaximize = True           ; make graphics large
 ;;res@gsnPaperOrientation = "portrait"   ; force for demo
   res@trXMinF = 0.0
   res@trXMaxF = tofloat(ny)

   res@vpHeightF= 0.4               ; change aspect ratio of plot
   res@vpWidthF = 0.8                  
   res@vpXF     = 0.1               ; start plot at x ndc coord

   yy  = new((/3,ny/),typeof(y))
   yy(0,:) = y
   yy(1,:) = yrun
   yy(2,:) = yxcl

   res@xyLineColors      = (/"blue","black","red"/)  ; line colors
   res@xyLineThicknesses = (/1,3,2/)        ; line thicknesses
   res@xyDashPatterns    = (/0,0,0/)        ; line patterns

   res@tiMainString   = "Match EXCEL"
   plot = gsn_csm_xy (wks,x,  yy  , res)
