function taylor_diagram (wks:graphic ,X[*][*]:numeric, Y[*][*]:numeric \
                                     ,rOpts:logical)
;
; Generate a Taylor Diagram:
; Generate Multiple Aspects of Model Performance in a Single Diagram
; Taylor, K. E., J. Geophys. Res., 106, D7, 7183-7192, 2001
;
; An example:
; http://www.grida.no/climate/ipcc_tar/wg1/fig8-4.htm
;
; This expects one or more datasets. The left dimension 
; is the number of datasets. The rightmost is the number of pts.
;
; Markers are at: 
; http://www.ncl.ucar.edu/Document/Graphics/Resources/gs.shtml
;
; By default, the function can handle up to 8 datasets.
; To expand modify the 'Colors' and 'Markers' attributes.
; The user can change / add some default settings.
;
; The defaults that the user can modify:
;
; rOpts                 = True 
                                   ; 'made-up' resources
; rOpts@Colors          =  (/ "black", "red", "green", "blue", "cyan" \
;                           , "torquoise", "brown", "yellow"/)
; rOpts@Markers         =  (/14, 4, 6, 14, 9, 12, 7, 4/) ; Marker Indices
; rOpts@markerTxOffset  = 0.0175   ; offset for text above marker

                                   ; standard NCL resources
; rOpts@tiMainString    = "Taylor" ; not using title makes plot bigger
; rOpts@gsMarkerSizeF   = 0.0085   ; marker size   
; rOpts@txFontHeightF   = 0.0125   ; text size 

; Script provided to UW by Bjorn Stevens, Atmos Sci. UCLA
; Matt Wyant
; Atmos Sci. Univ of Washington
; mwyant@atmos.washington.edu
; 5/26/06

; Actually, this is the NCL script which was made available via 
;           http://www.ncl.ucar.edu/Applications/index.shtml
;           Author: Dennis Shea
;
; It returns to the user a graphic object called "taylor".
; This graphic object contains a simple Taylor background appropriate
; for standardized data and the markers for the datasets.
 
; It is the users responsibility to add a legend if that is desired.
; ==================================================================
begin
  dimX                  = dimsizes(X)
  nDS                   = dimX(0)    ; # of datasets
  nPts                  = dimX(1)    ; # of data values
  
  xyMin                 = 0.  
  xyMax                 = 1.65
  xyOne                 = 1.00
 
  if (rOpts .and. isatt(rOpts,"txFontHeightF"))  then 
      FontHeightF       = rOpts@txFontHeightF    ; user wants to specify size
  else
      FontHeightF       = 0.0175
  end if

; ----------------------------------------------------------------
; Part 1:
; base plot: Based upon request of Mark Stevens
; basic x-y and draw the 1.0 observed and the outer curve at 1.65
; ----------------------------------------------------------------
  
  rxy                   = True       
  rxy@tiYAxisString     = "Standardized Deviations (Normalized)"
  rxy@tiYAxisFontHeightF= FontHeightF                        ; default=0.025 
  
  rxy@tmXBMode          = "Explicit" 
  rxy@tmXBValues        = (/0.0,0.25,0.50,0.75,1.00,1.25,1.5/)    ; major tm
                                                                  ; default  "OBS" or "REF"
  rxy@tmXBLabels        = (/"0.00","0.25","0.50","0.75","REF" ,"1.25","1.50"/)
  if (rOpts .and. isatt(rOpts,"OneX") )  then                     ; eg: rOpts@OneX="1.00"    
      rxy@tmXBLabels        = (/"0.00","0.25","0.50","0.75",rOpts@OneX,"1.25","1.50"/)
  end if

  rxy@tmXBMajorLengthF  = 0.015      ; default=0.02 for a vpHeightF=0.6
  rxy@tmXBLabelFontHeightF = FontHeightF
  rxy@tmXBMinorOn       = False
  rxy@trXMaxF           = xyMax

  rxy@tmYLMode          = "Manual"
  rxy@tmYLMinorOn       = False
  rxy@tmYLMajorLengthF  = rxy@tmXBMajorLengthF
  rxy@tmYLLabelFontHeightF = FontHeightF
  rxy@tmYLMode          = "Explicit" 
  rxy@tmYLValues        = (/0.0, .25,0.50, 0.75, 1.00, 1.25, 1.5/) ; major tm
  rxy@tmYLLabels        = (/"0.00","0.25","0.50","0.75","1.00","1.25","1.50"/)
  rxy@trYMaxF           = xyMax

  rxy@tmYRBorderOn      = False
  rxy@tmYROn            = False      ; Turn off right tick marks.

  rxy@tmXTBorderOn      = False
  rxy@tmXTOn            = False      ; Turn off right tick marks.

  rxy@xyDashPatterns    = (/1 , 0 /) ; line characteristics (dash,solid)
  rxy@xyLineThicknesses = (/1., 2./) ; choose line thickness

  rxy@gsnFrame          = False      ; Don't advance the frame.

                                            ; create outer 'correlation axis'
  npts         = 200                        ; arbitrary
 ;xx           = new (npts,float)
  yy           = new ((/2,npts/),float)
  xx           = fspan(xyMin,xyMax,npts) 
                                            ; activate if "OBSERVED" is to be printed
  ix           = ind(xx.le.1.0)
  nix          = dimsizes(ix)
  yy(0,:nix-1) = sqrt(xyOne   - xx(ix)^2)   ; inner  observed   line (1.0)
  yy(1,:)      = sqrt(xyMax^2 - xx^2    )   ; outer correlation line (xyMax)

  sLabels = (/"0.0","0.1","0.2","0.3","0.4","0.5","0.6" \ ; correlation labels
             ,"0.7","0.8","0.9","0.95","0.99","1.0"     /); also, major tm
  cLabels = stringtofloat(sLabels)
  rad     = 4.*atan(1.0)/180.
  angC    = acos(cLabels)/rad                     ; angles: correlation labels
                                                  ; chk for attributes
  if (rOpts .and. isatt(rOpts,"tiMainString")) then
      rxy@tiMainString  = rOpts@tiMainString
  end if
 ;if (rOpts .and. isatt(rOpts,"gsnCenterString")) then
 ;    rxy@gsnCenterString  = rOpts@gsnCenterString; only for gsn_csm_xy
 ;end if

  taylor  = gsn_xy(wks,xx,yy,rxy)                 ; Create and draw XY plot.

  getvalues taylor                                ; get style info from taylor
    "tmYLLabelFont"        : tmYLLabelFont        ; use for correlation axis
    "tmYLLabelFontHeightF" : tmYLLabelFontHeightF
  end getvalues

  delete(xx)
  delete(yy)
  delete(ix)
; ----------------------------------------------------------------
; Part 2:
; Concentric about 1.0 [OBS] on XB axis
; delete or comment out if this is not desired.
; ----------------------------------------------------------------
; I think this is correct. Still test mode.
; ----------------------------------------------------------------
  if (rOpts .and. isatt(rOpts,"centerDIffRMS") \     ; "centerDIffRMS"
            .and. rOpts@centerDIffRMS) then
      respl                    = True                ; polyline mods desired
      respl@gsLineThicknessF   = 1.0                 ; line thickness
      respl@gsLineColor        = "Black"             ; line color     
      respl@gsLineDashPattern  = 2                   ; short dash lines
      
      dx   = 0.25
      ncon = 4                                       ; 0.75, 0.50, 0.25, 0.0
      npts = 100                                     ; arbitrary
      ang  = fspan(180,360,npts)*rad

      do n=1,ncon 
         rr  = n*dx            ; radius from 1.0 [OBS] abscissa
         xx  = 1. + rr*cos(ang)
         yy  = fabs( rr*sin(ang) )
         if (n.le.2) then
             gsn_polyline(wks,taylor,xx,yy,respl)
         end if
         if (n.eq.3) then
             n3 = floattointeger( 0.77*npts ) 
             gsn_polyline(wks,taylor,xx(0:n3),yy(0:n3),respl)
         end if
         if (n.eq.4) then
             n4 = floattointeger( 0.61*npts ) 
             gsn_polyline(wks,taylor,xx(0:n4),yy(0:n4),respl)
         end if
      end do
      delete(ang)
      delete(xx)
      delete(yy)
  end if

; ----------------------------------------------------------------
; Part 3:
; Correlation labels
; ----------------------------------------------------------------
  radC    = xyMax                                  ; for correlation labels
  xC      = radC*cos(angC*rad)
  yC      = radC*sin(angC*rad)

;
; Convert to NDC coordinates so we can calculate labels positions
; that fall outside the taylor diagram data space.
;
  xCndc   = new(dimsizes(xC),typeof(xC))
  yCndc   = new(dimsizes(yC),typeof(yC))
  datatondc(taylor,xC,yC,xCndc,yCndc)
  xCndc   = xCndc + 0.007*cos(rad*angC)
  yCndc   = yCndc + 0.007*sin(rad*angC)

  txRes               = True                      ; text mods desired
  txRes@txFontHeightF = FontHeightF               ; match YL 
  txRes@tmYLLabelFont = tmYLLabelFont             ; match YL
  txRes@txAngleF      = -45.
  gsn_text(wks,taylor,"Correlation",1.30,1.30,txRes)
  txRes@txAngleF      = 0.0 
  txRes@txFontHeightF = FontHeightF*0.50          ; bit smaller
;;gsn_text(wks,taylor,"OBSERVED",1.00,0.075,txRes)

  plRes               = True
  plRes@gsLineThicknessF = 2.
  
  txRes@txJust        = "CenterLeft"              ; Default="CenterCenter".
  txRes@txFontHeightF = FontHeightF               ; match YL 

  tmEnd = 0.975
  radTM = xyMax*tmEnd                             ; radius end: major TM 
  xTM   = new( 2 , "float")
  yTM   = new( 2 , "float")

  do i=0,dimsizes(sLabels)-1                      ; Loop to draw strings
    txRes@txAngleF = angC(i)
    gsn_text_ndc(wks,sLabels(i),xCndc(i),yCndc(i),txRes) ; cor label
    xTM(0)   = xyMax*cos(angC(i)*rad)             ; major tickmarks at
    yTM(0)   = xyMax*sin(angC(i)*rad)             ; correlation labels
    xTM(1)   = radTM*cos(angC(i)*rad)             
    yTM(1)   = radTM*sin(angC(i)*rad)
    gsn_polyline(wks,taylor,xTM,yTM,plRes)
  end do
                                                  ; minor tm locations
  mTM     = (/0.05,0.15,0.25,0.35,0.45,0.55,0.65 \ 
             ,0.75,0.85,0.91,0.92,0.93,0.94,0.96,0.97,0.98  /)
  angmTM  = acos(mTM)/rad                         ; angles: correlation labels
  radmTM  = xyMax*(1.-(1.-tmEnd)*0.5)             ; radius end: minor TM 

  do i=0,dimsizes(mTM)-1                          ; manually add tm
    xTM(0)   = xyMax*cos(angmTM(i)*rad)           ; minor tickmarks
    yTM(0)   = xyMax*sin(angmTM(i)*rad)
    xTM(1)   = radmTM*cos(angmTM(i)*rad)          
    yTM(1)   = radmTM*sin(angmTM(i)*rad)
    gsn_polyline(wks,taylor,xTM,yTM,plRes)
  end do
; ---------------------------------------------------------------
; Part4:
; generic resources that will be applied to all users data points
; of course, these can be changed 
; http://www.ncl.ucar.edu/Document/Graphics/Resources/gs.shtml
; ---------------------------------------------------------------
  if (rOpts .and. isatt(rOpts,"Markers")) then
      Markers = rOpts@Markers
  else
      Markers = (/16, 4, 3, 14, 9, 12, 7, 2/) ; Marker Indices
  end if

  if (rOpts .and. isatt(rOpts,"gsMarkerThicknessF")) then
      gsMarkerThicknessF = rOpts@sMarkerThicknessF
  else
      gsMarkerThicknessF = 2.0
  end if

  if (rOpts .and. isatt(rOpts,"gsMarkerSizeF")) then
      gsMarkerSizeF      = rOpts@sMarkerSizeF
  else
      gsMarkerSizeF      = 0.0085                  ; Default: 0.007
  end if
    
  if (rOpts .and. isatt(rOpts,"Colors")) then
      Colors  = rOpts@Colors
  else
      Colors  = (/ "black", "red", "blue", "green", "cyan" \
                 , "torquoise", "brown", "yellow"/)
  end if

  gsRes = True
  gsRes@gsMarkerThicknessF = gsMarkerThicknessF      ; default=1.0
  gsRes@gsMarkerSizeF      = gsMarkerSizeF           ; Default: 0.007 

  ptRes = True                        ; text options for points
  ptRes@txJust             = "BottomCenter"; Default="CenterCenter".
  ptRes@txFontThicknessF   = 1.3      ; default=1.00
  ptRes@txFontHeightF      = 0.0125   ; default=0.05
  if (rOpts .and. isatt(rOpts,"txFontHeightF")) then
      ptRes@txFontHeightF  = rOpts@txFontHeightF  
  end if

  markerTxYOffset          = 0.0175   ; default
  if (rOpts .and. isatt(rOpts,"markerTxYOffset")) then
      markerTxYOffset = rOpts@markerTxYOffset             ; user defined offset
  end if

  do n=0,nDS-1
     gsRes@gsMarkerIndex  = Markers(n) ; marker style 
     gsRes@gsMarkerColor  = Colors(n)  ; marker color
     ptRes@txFontColor    = gsRes@gsMarkerColor

    do i=0,nPts-1
       gsn_polymarker(wks,taylor,X(n,i),Y(n,i),gsRes) 
       gsn_text(wks,taylor,(i+1),X(n,i),Y(n,i)+markerTxYOffset,ptRes)
    end do
  end do

 ;frame(wks)             ; do *not* advance the frame

  return(taylor)
end

