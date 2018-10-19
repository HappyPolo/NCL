;************************************************
; taylor_6.ncl: requires NCL 4.2.0.a034 or higher
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;
; This file still has to be loaded manually 
load "./taylor_diagram.ncl"
;**********************************

begin
; variables compared
  var       = (/ "SLP","Tsfc","Prc","Prc 30S-30N","LW","SW", "U300", "Guess" /) 
  nVar      = dimsizes(var)                   ; # of Variables

  cases     = (/"Case A", "Case B", "Case C", "Case D", "Case E"/)
  nCase     = dimsizes( cases  )

; *******************************************************************
; Open wks and set plot options
; *******************************************************************
  wks   = gsn_open_wks("png","taylor")      ; send graphics to PNG file
  plot  = new(5,graphic)        

  opt            = True                     ; taylor diagram with options
  opt@Markers    = (/16,16,16,16,16/)       ; make all "cases" solid fill
  opt@Colors     = (/"red","blue","green","magenta","orange" /)          
  opt@varLabels  = var
  opt@varLabelsYloc = 0.65
  opt@caseLabels = (/"Case A", "Case B","Case C","Case D","Case E"/)
  
  opt@taylorDraw  = False                          ; don't draw
  opt@taylorFrame = False                          ; don't advance frame

; *******************************************************************
; Generate one plot for each season + annual.
; *******************************************************************
  opt@tiMainString = "DJF"
  ratio     = random_normal ( 1.0, 0.25, (/nCase, nVar/) )
  cc        = random_uniform( 0.7, 1.00, (/nCase, nVar/) )
  plot(0)   = taylor_diagram(wks,ratio,cc,opt)

  opt@tiMainString = "JJA"
  ratio     = random_normal ( 1.0, 0.25, (/nCase, nVar/) )
  cc        = random_uniform( 0.7, 1.00, (/nCase, nVar/) )
  plot(1)   = taylor_diagram(wks,ratio,cc,opt)

  opt@tiMainString = "MAM"
  ratio     = random_normal ( 1.0, 0.25, (/nCase, nVar/) )
  cc        = random_uniform( 0.7, 1.00, (/nCase, nVar/) )
  plot(2)   = taylor_diagram(wks,ratio,cc,opt)

  opt@tiMainString = "SON"
  ratio     = random_normal ( 1.0, 0.25, (/nCase, nVar/) )
  cc        = random_uniform( 0.7, 1.00, (/nCase, nVar/) )
  plot(3)   = taylor_diagram(wks,ratio,cc,opt)

  opt@tiMainString = "ANNUAL"
  ratio     = random_normal ( 1.0, 0.25, (/nCase, nVar/) )
  cc        = random_uniform( 0.7, 1.00, (/nCase, nVar/) )
  plot(4)   = taylor_diagram(wks,ratio,cc,opt)

; *******************************************************************
; Create demo panels
; *******************************************************************
  resP = True
 ;resP@txString = "PANEL DEMO"
  resP@gsnPanelYWhiteSpacePercent = 3    ; add extra white space

  gsn_panel(wks,plot(0:1),(/2,1/),resP)

  resP@gsnPanelRowSpec = True                   ; tell panel what order to plt
  gsn_panel(wks,(/plot(0),plot(1),plot(4)/),(/2,1/),resP)
  delete(resP@gsnPanelRowSpec)

  gsn_panel(wks,plot(0:3),(/2,2/),resP)

end 
