;*************************************************
; manken_1.ncl
;
; Concepts illustrated:
;   - Read tabular values from an ascii file
;   - Extract desired columns using NCL array syntax
;   - Extract 2 sub-periods and entire period
;   - Calculate linear regression coef and Theil-Sen slope
;     for each period
;   - Plot
;*************************************************

;-----------------------------------------------------
; Read ascii (text) file
;-----------------------------------------------------
   diri = "./"
   fili = "TA_Globe.1850-2014.txt"
   pthi = diri+fili

   nrow = numAsciiRow(pthi)
   ncol = 12
   data = asciiread(pthi,(/nrow,ncol/),"float")
   data@_FillValue = -999

   year = data(:,0)
   ta   = data(:,1)      ; explicitly extract desired column
   nta  = dimsizes(ta)

;-----------------------------------------------------
; plot resources
;-----------------------------------------------------
  plot = new(3,"graphic") 

  wks  = gsn_open_wks("png","manken")        ; send graphics to PNG file
 
  res                     = True                   ; plot mods desired
  res@gsnDraw             = False                  ; don't draw yet      
  res@gsnFrame            = False                  ; don't advance frame yet      

  res@xyDashPatterns      = 0                      ; solid line 
  res@xyLineColors        = (/"black", "red", "blue"/) 
  res@xyLineThicknesses   = (/1,3,1/)                
  res@tiMainString        = fili                   ; title

  res@vpHeightF           = 0.4                    ; change aspect ratio of plot
  res@vpWidthF            = 0.8                  
  res@vpXF                = 0.1                    ; start plot at x ndc coord 

  res@trXMinF  = year(0) 
  res@trXMaxF  = year(nta-1)+1
  res@trYMinF  = -0.6      
  res@trYMaxF  =  0.6
  res@gsnYRefLine      = 0.0

  txres               =  True
  txres@txFontHeightF = 0.02
  txres@txJust        = "CenterCenter"
  txres@txFontThicknessF = 2.0      ; default=1.00
  txres@txFontHeightF    = 0.025    ; default=0.05

;-----------------------------------------------------
; Partition source time series into three parts
; .   ntry=1    ; 1st half of time series
; .   ntry=2    ; 2nd half of time series
; .   ntry=3    ; all years
;-----------------------------------------------------
; For each partition, calculate 
; .   Simple linear regression line 
; .   Mann-Kendall and Thiel-Sen estimates 
;-----------------------------------------------------
; Do not plot immediately
;-----------------------------------------------------

  dplt = new ( (/3,nrow/), typeof(ta), ta@_FillValue)

  do ntry=1,3                ; break series into 3 segments
     if (ntry.eq.1) then
         ntStrt = 0
         ntLast = nta/2-1      
       else if (ntry.eq.2) then
         ntStrt = nta/2       
         ntLast = nta-1
       else
         ntStrt = 0
         ntLast = nta-1
       end if
     end if
  
     rc   = regline(year(ntStrt:ntLast),ta(ntStrt:ntLast))
     p    = trend_manken(ta(ntStrt:ntLast), False, 0)
  
     dplt = ta@_FillValue
     dplt(0,ntStrt:ntLast) = ta(ntStrt:ntLast)
     dplt(1,ntStrt:ntLast) = rc*(year(ntStrt:ntLast)-rc@xave) + rc@yave
     dplt(2,ntStrt:ntLast) = p(1)*(year(ntStrt:ntLast)-rc@xave) + rc@yave
  
     plot(ntry-1)  = gsn_csm_xy (wks,year,dplt,res)           ; create plot
  
     text          = "p="+sprintf("%5.3f",p(0))+"  trend="+sprintf("%5.3f",p(1))
     plot@$unique_string("dum")$ = gsn_add_text(wks,plot(ntry-1),text, 1950, 0.30 ,txres)
  end do

;********************************************
; create attached plots
;********************************************

; Set up resource lists for attaching the plot.  The res1 will apply to the base plot, 
; and the res2 to the plots being attached.  These resources lists are *not* for 
; changing things like line color, but for changing things like whether the plots
; are maximized, and which axis they are attached on.
 
  res1                     = True
  res2                     = True
  res2@gsnAttachPlotsXAxis = True
  amid = gsn_attach_plots(plot(0),(/plot(1),plot(2)/),res1,res2)
  draw(plot(0))
  frame(wks)
