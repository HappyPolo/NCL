;***************************************************************
; eemd_1.ncl    
;
; Concepts illustrated:
;   - Creating a sinusoid using array syntax  
;   - Specifying 'eemd' options
;   - Printing min / max of each IMF
;   - Adding figure strings to paneled plots
;***************************************************************
; Requires NCL 6.4.0 or higher
;***************************************************************
;; Based upon:
;; https://journal.r-project.org/archive/2009-1/RJournal_2009-1_Kim+Oh.pdf
;***************************************************************

; Create input data

   N   = 3000
   tt  = fspan(0, 9, N)           ; x-axis (float)
   rad = get_d2r(typeof(tt))      ; 6.4.0
   pi  = get_pi (typeof(tt))      ; 6.4.0
  
   xt = sin(pi*tt) + sin(2*pi*tt) + sin(6*pi*tt) + 0.5*tt
  ;print(tt+"   "+xt)

; set 'eemd' options
 
   nrep  = 250
   nimf  = 10                     ; nimf=0 , function will calculate
   noise = 0.2
   dims  = 0
   opt   = False

   e     = eemd(xt,nimf,nrep,noise,opt,dims)     ; (nimf,N) 
   e@long_name = "EEMD"
   printVarSummary(e)
   printMinMax(e,0)

   dime  = dimsizes(e)
   NIMF  = dime(0)                               ; if input nimf=0 (NIMF is calculated)
   NN    = dime(1)                               ; same as N

; plot

   wks   = gsn_open_wks("png","eemd")
   res   = True

   res@vpHeightF = 0.4                           ; change aspect ratio of plot
   res@vpWidthF  = 0.75                 
   res@vpXF      = 0.15                          ; start plot at x ndc coord 

                                                 ; for esthetic purposes only
   res@trXMinF   = min(tt) - 10*(tt(1)-tt(0))    ; extra space at left  boundary
   res@trXMaxF   = max(tt) + 10*(tt(1)-tt(0))    ; extra space at right boundary
   
; sinusoid

   res@tiMainString = "Sinusoid"
   plt  = gsn_csm_xy(wks,tt,xt,res)              ; raw data
   delete(res@tiMainString)

; plot each IMF

   plot = new (NIMF,"graphic")

   res           = True
   res@gsnDraw   = False                         ; don't draw
   res@gsnFrame  = False                         ; don't advance frame

   do ni=0,NIMF-1                                ; loop over each IMF
      e@long_name = "NIMF_"+(ni+1)
      printMinMax(e(ni,:),0)                    
      delete(e@long_name)                        ; do not want on plot

     ;res@tiMainString = "EEMD: NIMF_"+(ni+1)
      plot(ni) = gsn_csm_xy(wks,tt,e(ni,:),res)  ; each IMF

   end do

; create panel of IMFs

  resP = True                                          ; modify the panel plot
  resP@gsnMaximize           = True
  resP@gsnPanelMainString    = "eemd: sinusoid"        ; new resource added in NCL V6.4.0
  resP@gsnPanelFigureStrings = "IMF "+ispan(1,NIMF,1)  ; add strings to panel
  resP@gsnPanelFigureStringsJust = "TopLeft"           ; new resource added in NCL V6.4.0
  gsn_panel(wks,plot,(/5,2/),resP)                     ; now draw as one plot

