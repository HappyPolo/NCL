; ***********************************************
; omega_2.ncl
;
; Concepts illustrated:
;   - Computing omega from CCSM output.
;   - Drawing a black-and-white XY plot
;   - Drawing a X reference line in an XY plot
;   - Drawing a legend inside an XY plot
;   - Reversing the Y axis
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
  ntStrt = 0
  ntLast = 0
  f    = addfile("/ptmp/shea/OMEGA/debug_omega.cam2.h0.0000-01-01-00000.nc", "r")
  u    = f->U(ntStrt:ntLast,:,:,:)       ; (time,lev|26,lat|128,lon|256)
  v    = f->V(ntStrt:ntLast,:,:,:)
  p0   = f->P0                 ; reference pressure
  hyai = f->hyai               ; interface "a" hybrid coefficients
  hybi = f->hybi               ;           "b"
  ps   = f->PS(ntStrt:ntLast,:,:)
  hyam = f->hyam
  hybm = f->hybm
  lev  = f->lev
  
;************************************************************
; Compute divergence at each hybrid level [spherical harmonics]
;************************************************************  
  div  = uv2dvG_Wrap(u,v)      ; divergence (1/s) on each hybrid level
  printVarSummary(div)
  printMinMax(div, True)
;************************************************************
; Compute delta-p at each grid pt
;************************************************************
  dpi = dpres_hybrid_ccm(ps,p0,hyai,hybi)   

;************************************************************
; Compute delta omega at each hybrid level via kinematic method
; .  see eqn 8.20 in Wallace and Hobbs
;************************************************************
  omega = div
  omega = div*dpi
  omega@long_name = "delta OMEGA at each hybrid level: eqn 8.20 Wallace and Hobbs"
  omega@units     = "Pa/s"
  omega@method    = "derived via kinematic method: div*dp"
  printVarSummary(omega)
  printMinMax(omega, True)

  dimo  = dimsizes(omega)
  klev  = dimo(1)
;************************************************************
; integrate [sum] the delta-omega [bottom->top]
; .  store back into the omega variable array
; .  assume that omega at sfc of atmosphere is 0.0
; .  the funky omega subscript is because omega goes top->bottom
; .  while temp goes from sfc to top [after reordering]
;************************************************************

  temp  = omega(time|:,lat|:,lon|:,lev|::-1)      ; reshape array for function
  dimt  = dimsizes(temp)
  klev  = dimt(3)
  oBot  = 0.0                                     ; explicit
  
  do kl=0,klev-1                             
     omega(:,klev-1-kl,:,:) = oBot + dim_sum(temp(:,:,:,0:kl))   
  end do
  omega@long_name = "OMEGA"
  omega@method    = "derived via kinematic method: eqn 8.20 Wallace and Hobbs"
  printVarSummary(omega)
  printMinMax(omega, True)
  delete(temp)                   ; no longer needed 
;************************************************************
; Use O'Brian adjustment scheme
; Bluestein: Volume I: pp 315-316
; in practice: no need to use separate array [used for graphic below]
;************************************************************

  oTop = 0.0                     ; omega_trop in book [upper b.c.]
  pTop = 0.0                     ; p_trop in book [upper b.c.]
  pm   = pres_hybrid_ccm(ps,p0,hyam,hybm)   ; pressure at each level

  omega_adj = omega              ; new array with meta data
  
  do kl=0,klev-1                             
    omega_adj(:,klev-1-kl,:,:)  = omega(:,klev-1-kl,:,:) \
         + (oTop-omega(:,klev-1-kl,:,:))*((ps-pm(:,klev-1-kl,:,:))^2/(ps-pTop)^2)
  end do
  omega_adj@long_name = "OMEGA adjusted"
  omega_adj@info      = "OBrian Adjustment: see Bluestein: Volume I: pp 315-316"
  printMinMax(omega_adj, True)
;======================================================================================
  
  omega_model = f->OMEGA(ntStrt:ntLast,:,:,:)	;Read in model calculated omega  
  
;======================================================================================
; Calculate OMEGA using ncl function omega_ccm_driver locatied in contributed.ncl
;======================================================================================
  omega_ncl = omega_ccm_driver(p0,ps,u,v,hyam,hybm,hyai,hybi)    
  
;======================================================================
;	Begin plotting section. Will plot omega calculated by:
;	1) CCM model (in omega_model) 2) NCL omega_ccm_driver function (in omega_ncl)
;	3) Kinematic method detailed in Wallace and Hobbs (in omega)
;	4) OBrian Adjustment to kinematic method detailed in Bluestein (in omega_adj)
;======================================================================
  wks = gsn_open_wks("ps","omega_2")    
 
  latPlt = (/ 10, 30, 45, 40/) 
  lonPlt = (/180,180,300,270/) 
  nPlt   = dimsizes(latPlt)
  plt    = new(nPlt,graphic)                          ; create graphics array

  y      = new((/4,klev/), typeof(omega))
  y@long_name = "Vertical pressure velocity"
  lev@long_name = "nominal hybrid pressure"
  resxy                   = True                      ; plot mods desired
  resxy@gsnDraw           = False                     ; Do not draw plot
  resxy@gsnFrame          = False                     ; Do not advance frome
  resxy@gsnXRefLine       = 0.0                       ; draw ref line
  resxy@trYReverse        = True                      ; reverse Y-axis
  resxy@xyLineThicknesses = (/2.0,2.0,2.0,2.0/)           
  resxy@xyLineColors      = (/"black","red","green","blue"/)          ; change line colors
  resxy@trYMinF           = 0.0
  resxy@trYMaxF           = 1000.0

  resxy@pmLegendDisplayMode    = "Always"             ; turn on legend
  resxy@xyExplicitLegendLabels = (/" NCL"," CCM"," adjusted"," kinematic"/)
  resxy@pmLegendSide           = "Top"                ; Change location of 
  resxy@lgPerimOn = False
  resxy@pmLegendWidthF         = 0.15                   ; Change width and
  resxy@pmLegendHeightF        = 0.2                   ; height of legend.
  resxy@lgLabelFontHeightF     = .025                   ; change font height

  val1 = (/-1.,-1.,-.45,-.45/)
  val2 = (/.75,.25,.25,.25/)


  do np=0,nPlt-1
     resxy@pmLegendParallelPosF   = val2(np)                  ; move units right
     resxy@pmLegendOrthogonalPosF = val1(np)                ; move units down
     resxy@tiMainString = "["+latPlt(np)+","+lonPlt(np)+"]"
     y(0,:)   = (/ omega_ncl(0,:,{latPlt(np)},{lonPlt(np)}) /)
	y(1,:)   = (/ omega_model(0,:,{latPlt(np)},{lonPlt(np)}) /)
	y(2,:)   = (/ omega_adj(0,:,{latPlt(np)},{lonPlt(np)}) /)
	y(3,:)   = (/ omega(0,:,{latPlt(np)},{lonPlt(np)}) /)     
     plt(np)  = gsn_csm_xy (wks,y,lev,resxy) 
  end do
  resPanel                 = True                ; panel mods desired
  resPanel@gsnMaximize     = True                ; fill up the page
  resPanel@lbLabelAutoStride = True

  resPanel@txString   = "OMEGA"
  gsn_panel(wks,plt,(/2,2/),resPanel)    
end
