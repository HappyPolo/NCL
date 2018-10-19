;**********************************
; taylor_3.ncl
;**********************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;
; This file still has to be loaded manually 
load "./taylor_diagram.ncl"
;**********************************
begin
;**********************************
; Assume the following have already been computed:
;   _ratio are the ratio:  Case_Variance/Reference_Variance
;   _cc    are the cross correlation coef of Case to Reference
;**********************************

; Cases [Model]
  case      = (/ "Case A", "Case B" /) 
  nCase     = dimsizes(case )                 ; # of Cases [Cases]

; variables compared
  var       = (/ "SLP","Tsfc","Prc","Prc 30S-30N","LW","SW", "U300", "Guess" /) 
  nVar      = dimsizes(var)                   ; # of Variables

; "Case A"                        
  CA_ratio   = (/1.230, 0.988, 1.092, 1.172, 1.064, 0.966, 1.079, 0.781/)
  CA_cc      = (/0.958, 0.973, 0.740, 0.743, 0.922, 0.982, 0.952, 0.433/)

; "Case B" 
  CB_ratio   = (/1.129, 0.996, 1.016, 1.134, 1.023, 0.962, 1.048, 0.852 /)
  CB_cc      = (/0.963, 0.975, 0.801, 0.814, 0.946, 0.984, 0.968, 0.647 /)

; arrays to be passed to taylor plot 
  ratio      = new ((/nCase, nVar/),typeof(CA_cc) )  
  cc         = new ((/nCase, nVar/),typeof(CA_cc) ) 

  ratio(0,:) = CA_ratio 
  ratio(1,:) = CB_ratio

  cc(0,:)    = CA_cc 
  cc(1,:)    = CB_cc

;**********************************
; create plot
;**********************************

  res   = True                           ; default taylor diagram
        
  res@Markers      = (/16, 16/)               ; make all solid fill
  res@Colors       = (/"red", "blue" /)          
  res@varLabels    = var
  res@caseLabels   = case
 
  wks   = gsn_open_wks("png","taylor")        ; send graphics to PNG file 
  plot  = taylor_diagram(wks,ratio,cc,res)


end 
