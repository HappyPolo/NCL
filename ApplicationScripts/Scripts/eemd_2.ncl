;***************************************************************
; eemd_2.ncl    
;
; Concepts illustrated:
;   - Using "where" function to create an intermittent
;   - Specifying 'eemd' options
;   - Printing min / max of each IMF
;   - Adding figure strings to paneled plots
;
;***************************************************************
; Requires NCL 6.4.0 or higher
;***************************************************************
;; Based upon:
;; https://journal.r-project.org/archive/2009-1/RJournal_2009-1_Kim+Oh.pdf
;***************************************************************

; create x axis

   N   = 2001
   tt  = fspan(0, 0.1, N)

; create intermittent signal

   rad = get_d2r(typeof(tt))      ; 6.4.0
   pi  = get_pi (typeof(tt))      ; 6.4.0
   f1  = 1776
   f2  = 1000

   arg1= 2*pi*f1*tt
   arg2= 2*pi*f2*tt

   xt = where(tt.ge.(1.0/30) .and. tt.le.(2.0/30) \
             ,sin(arg1), sin(arg1)+sin(arg2)      )
  ;print(tt+"   "+xt)

; set 'eemd' options

   nrep  = 200
   nimf  = 10
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
   
; plot Intermittent Signal sinusoid

   res@gsnMaximize  = True
   res@tiMainString = "Intermittent Signal"
   plt  = gsn_csm_xy(wks,tt,xt,res)              ; raw data
   delete([/res@tiMainString, res@gsnMaximize/]) ; do not want on subsequent plots

; plot each IMF

   plot = new (NIMF,"graphic")

   res           = True
   res@gsnDraw   = False                         ; don't draw
   res@gsnFrame  = False                         ; don't advance frame

   do ni=0,NIMF-1                                ; loop over each IMF
      e@long_name = "NIMF_"+(ni+1)
      printMinMax(e(ni,:),0)                    
      delete(e@long_name)                        ; do not want on plot

      plot(ni) = gsn_csm_xy(wks,tt,e(ni,:),res)  ; each IMF
   end do

; create panel of IMFs

   resP = True                                    ; modify the panel plot
   resP@gsnMaximize               = True
   resP@gsnPanelMainString        = "eemd: Intermittent Signal"    ; new resource added in NCL V6.4.0
   resP@gsnPanelFigureStrings     = "IMF "+ispan(1,NIMF,1)         ; add strings to panel
   resP@gsnPanelFigureStringsJust = "TopLeft"                      ; new resource added in NCL V6.4.0

   gsn_panel(wks,plot,(/5,2/),resP)             ; now draw as one plot
