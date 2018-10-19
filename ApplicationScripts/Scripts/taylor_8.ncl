;**********************************
; taylor_8.ncl
;**********************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;
; This file still has to be loaded manually 
load "./taylor_diagram_cam.ncl"
;**********************************
begin
;**********************************
; Assume the following have already been computed:
;   _ratio are the ratio:  Case_Variance/Reference_Variance
;   _cc    are the cross correlation coef of Case to Reference
;   _bias  are the bias estimates 
;**********************************

; Cases [Model]
  case      = (/ "Data A", "Data B" /) 
  nCase     = dimsizes(case )                 ; # of Cases [Cases]

; variables compared
  var       = (/ "Globe","20S-20N","Land", "Ocean", "N. America", "Africa" /) 
  nVar      = dimsizes(var)                   ; # of Variables

; "Case A"                        
  CA_ratio   = (/1.230, 0.988, 1.092, 1.172, 1.064, 0.990 /)
  CA_cc      = (/0.958, 0.973,-0.740, 0.743, 0.922, 0.950 /)
  BA         = (/2.7  ,-1.5  , 17.31,-20.11, 12.5 , 8.341 /) 

; "Case B" 
  CB_ratio   = (/1.129, 0.996, 1.016, 1.134, 1.023, 0.962 /)
  CB_cc      = (/0.963, 0.975, 0.801, 0.814,-0.946, 0.984 /)
  BB         = (/1.7  , 2.5  ,-17.31, 20.11, 19.5 , 7.341 /) 

; arrays to be passed to taylor plot 
  ratio      = new ((/nCase, nVar/),typeof(CA_cc) )  
  cc         = new ((/nCase, nVar/),typeof(CA_cc) ) 
  bias       = new ((/nCase, nVar/),typeof(CA_cc) ) 

  ratio(0,:) = CA_ratio 
  ratio(1,:) = CB_ratio

  cc(0,:)    = CA_cc 
  cc(1,:)    = CB_cc

  bias(0,:)  = BA
  bias(1,:)  = BB

;**********************************
; create plot
;**********************************

  res   = True                           ; default taylor diagram
        
  res@Markers      = (/16, 16/)               ; make all solid fill
  res@Colors       = (/"red", "blue" /)          
  res@varLabels    = var
  res@caseLabels   = case
 
  wks   = gsn_open_wks("png","taylor")        ; send graphics to PNG file
  plot  = taylor_diagram_cam(wks,ratio,cc,bias,res)
end 

