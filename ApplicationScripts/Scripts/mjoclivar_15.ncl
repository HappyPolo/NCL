;,***********************************************************
; Plot Phase Space Diagram
;***********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl" 

begin
  ymdStrt = 19961016                         ; start yyyymmdd
  ymdLast = 19970415                         ; last  

  pltDir  = "./"                             ; plot directory
  pltType = "ps"  
  pltName = "mjoclivar"                      ; +"."+yrStrt+"_"+yrLast

  pltMovie= False                            ; animation
  pltTitle= "MJO Phase: 15S-15N: "+ymdStrt+"-"+ymdLast

;;if (pltType.eq."png") then                 ; optional
;;    pltType@wkWidth  = 1500
;;    pltType@wkHeight = 1500
;;end if

;***********************************************************
; Open PC components file created in 'mjo_14.ncl'
;***********************************************************
  diri    = "./"                             ; input directory   
  fMJO    = "MJO_PC_INDEX.nc"                ; created in mjo_14.ncl
  f       = addfile (diri+fMJO, "r")

;***********************************************************
; Find the indices corresponding to the start/end times
;***********************************************************
  TIME    = f->time                          ; days since ...
  YMD     = cd_calendar(TIME, -2)            ; entire (time,6)

  iStrt   = ind(YMD.eq.ymdStrt)              ; index start
  iLast   = ind(YMD.eq.ymdLast)              ; index last 
  delete(TIME)
  delete(YMD )

;***********************************************************
; Read the data for the desired period
;***********************************************************
  pc1     = f->PC1(iStrt:iLast)
  pc2     = f->PC2(iStrt:iLast)
  mjo_indx= f->MJO_INDEX(iStrt:iLast)

  time    = f->time(iStrt:iLast)
  ymdhms  = cd_calendar(time, 0)

  ntim    = dimsizes( time )

;------------------------------------------------------------
; PLOT
;------------------------------------------------------------

   opt                       = True           ; Background options 
  ;opt@gsnMaximize           = True           ; make large
   opt@tiMainString          = pltTitle

   plMark                    = True           ; poly marker
   plMark@gsMarkerIndex      = 16             ; solid circle  
   plMark@gsMarkerSizeF      = 0.005 
   plMark@gsMarkerThicknessF =  1

   plLine                    = True           ; line segments
   plLine@gsLineThicknessF   = 1.0            ; 1.0 is default 

   txres                     = True
   txres@txFontHeightF       = 0.010          ; size of font for printed day 

   namMonth = (/ "Jan","Feb","Mar","Apr","May","June" \
               ,"July","Aug","Sep","Oct","Nov","Dec" /)

   colMonth = (/2,3,5,6,7,8,10,11,12,13,18,20/)   ; indices into color table

   imon = floattoint( ymdhms(:,1) )   ; convenience
   iday = floattoint( ymdhms(:,2) )   ; sunscripts must be integer

   pltPath = pltDir+pltName
   if (.not.pltMovie) then
       wks  = gsn_open_wks(pltType, pltPath)  ; open workstation
			 gsn_define_colormap(wks,"radar_1")
   end if

   plot = mjo_phase_background(wks, opt)      ; generic phase space background
   xBegin= pc1(0)                             ; need for start of the line
   yBegin= pc2(0)
      
   plMark@gsMarkerColor = "black"             ; indicate initial point
   plMark@gsMarkerSizeF = 2.5*plMark@gsMarkerSizeF  ; make larger
   plot@$unique_string("dum")$ = gsn_add_polymarker(wks, plot, xBegin, yBegin, plMark)
   plMark@gsMarkerSizeF = plMark@gsMarkerSizeF/2.5  ; reset

   nMon            = 0
   monInfo         = new ((/12,2/),"string")
   monInfo(nMon,0) = namMonth(imon(0)-1) 
   monInfo(nMon,1) = colMonth(imon(0)-1) 
   
   label_opt       = 5                ; label every # day   0 = don't label days
   label_color     = True             ; draw month label with its proper color
	 
   do nt=1,ntim-1
      if (pltMovie) then
          ext = "_"+sprinti("%4.0i", nt )
          wks = gsn_open_wks(pltType,pltName+ext)  
					gsn_define_colormap(wks,"radar_1")
      end if
                                                    ; color changes w month 
      plLine@gsLineColor = colMonth(imon(nt)-1)     ; -1 is cuz NCL is 0-based
      plot@$unique_string("dum")$ = gsn_add_polyline(wks, plot, (/xBegin,pc1(nt)/), (/yBegin,pc2(nt)/), plLine)
      
      if (label_opt.eq.0) then
	  plMark@gsMarkerColor = plLine@gsLineColor ; same as line color
          plot@$unique_string("dum")$ = gsn_add_polymarker(wks, plot, xBegin, yBegin, plMark)
      else
         if (iday(nt)%label_opt.eq.0) then                   
            txres@txFontColor           = "black"     
            plot@$unique_string("dum")$ = gsn_add_text(wks, plot, iday(nt)+"", xBegin, yBegin, txres)
         else                                          ; marker only
            plMark@gsMarkerColor = plLine@gsLineColor  ; same as line color
            plot@$unique_string("dum")$ = gsn_add_polymarker(wks, plot, xBegin, yBegin, plMark)
         end if
      end if

      if (iday(nt).eq.1) then
          nMon = nMon+1
          monInfo(nMon,0) = namMonth(imon(nt)-1) 
          monInfo(nMon,1) = colMonth(imon(nt)-1) 
      end if

      if (pltMovie) then
          draw(plot)                                           
          frame(wks)                                         
      end if

      xBegin= pc1(nt)                            
      yBegin= pc2(nt)
   end do

   plMark@gsMarkerColor = "black"             ; indicate last point
   plMark@gsMarkerSizeF = 2.5*plMark@gsMarkerSizeF  ; make larger
   plot@$unique_string("dum")$ = gsn_add_polymarker(wks, plot, xBegin, yBegin, plMark)

   if (.not.pltMovie) then
       if (label_color) then                ; fancy coloring of months
           getvalues plot
	       "trXMinF" : xmin
	   end getvalues
	   xinc = (xmin*-2) / (nMon+1+2.)   ; total number months = nMon+1. +2 
                                            ; for spacing on ends
           txres@txJust        = "CenterLeft"
           txres@txFontHeightF = 0.013      ; size of font for printed month
           xstart = xmin+(1.25*xinc)   
           if (nMon.gt.0) then
               do n=0, nMon
                  txres@txFontColor = monInfo(n,1)
	          plot@$unique_string("dum")$ =  gsn_add_text(wks, plot, monInfo(n,0) ,xstart , -3.75, txres)
                  xstart = xstart+xinc
               end do
           end if
       end if
       draw(plot)                                           
       frame(wks)                                         

       if (pltType.eq."png") then
           if (isatt(opt,"pltConvert")) then
               pltConvert = opt@pltConvert    ; convert options
           else
               pltConvert = "-trim +repage -border 8 -bordercolor white"
           end if
           system("convert "+pltConvert+" "+pltPath+".png "+pltPath+".png")
       end if

     end if
end

