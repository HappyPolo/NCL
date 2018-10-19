; ===============================================
; filter_9.ncl
; ===============================================
;
undef("bf_BandPassResponse")
;==========================================================================
; Calculate the response function of the Butterworth band pass filter
; The filter is optimized for narrow bands. 
; http://www.seismosoc.org/publications/BSSA_html/bssa_96-2/05055-esupp/
;==========================================================================
function bf_BandPassResponse(M[1]:integer,f1[1]:numeric,f2[1]:numeric,N[1]:integer)
local fStrt, fLast, f, M2, fc, p1, p2, p1p2m2
begin

  fStrt  = 1d0/N     ; smallest frequency
  fLast  = 0.5d0     ; Nyquist
  f      = fspan(fStrt,fLast,N)

  M2     = 2*M
  fc     = (f1+f2)*0.5d0    ; center frequency

  p1     = (f^2-f1*f2)      ; partition terms for clarity
  p2     = (f*abs(f2-f1))
  p1p2m2 = (p1/p2)^M2

  rbp    = 1d0/(1d0+p1p2m2) 
  rbp@long_name = "Response"
  rbp@frq= (/f1, fc, f2/)
  rbp@M  = M                 

  return([/ f, rbp /])
end
;===================  MAIN===========================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

   c1 = 60       ; start
   c2 = 30       ; end

   f1 = 1d0/c1   ; start frequency
   f2 = 1d0/c2   ; end       "

   N  = 1000     ; used for plotting

   mStrt=4       ; odd or even
   mLast=10      ; max is 10
   mJump=2       ; mjump=1

   nresp = (mLast-mStrt)/mJump+1
   resp  = new ((/nresp,N/),"double") 

   m = -1
   do M=mStrt,mLast,mJump     ; order of Butterworth filter   

      fr = bf_BandPassResponse(M,f1,f2,N)
      f  = fr[0]

      m = m+1
      resp(m,:) = fr[1]
   end do

   pltDir  = "./"
   pltType = "png"
  ;pltName = "bf_BandPassResponse."+c2+"_"+c1
   pltName = "filters"
   wks     = gsn_open_wks (pltType,pltDir+pltName)  

   gres                  = True                     ; plot mods desired
   gres@gsnDraw          = False
   gres@gsnFrame         = False
   gres@trYMinF          = -0.1
   gres@trYMaxF          =  1.1
   gres@gsnYRefLine      =  0.0 
   gres@tiMainString     = "Butterworth Band Pass: "+c2+"-"+c1

   gres@xyLineThicknessF = 2.0
   gres@xyLineColor      = "blue"

   iStrt = 0               
   iLast = N-1

   gres@gsnCenterString = "f1="+sprintf("%5.3f",f1)+", f1="+sprintf("%5.3f",f1) \
                                                   +", f2="+sprintf("%5.3f",f2) 
   plot  = gsn_csm_xy (wks,f(iStrt:iLast),resp(:,iStrt:iLast),gres) ; create plot
    
   X = (/0.0, f1 , f1 , f2 , f2 , f(iLast)/)      ; ideal filter
   Y = (/0.0, 0.0, 1.0, 1.0, 0.0,  0.0 /) 

   resGs = True
   resGs@gsLineThicknessF = 1.0

   gsn_polyline(wks,plot,X,Y,resGs)

   draw(plot)                                      ; draw
   frame(wks)

   i1 = ind(f.lt.f1)                ; only plot near filter
   i2 = ind(f.gt.f2)
   iStrt = max( (/i1(0)-50, 0  /) )
   iLast = min( (/i2(0)+50, N-1/) )

   plot  = gsn_csm_xy (wks,f(iStrt:iLast),resp(:,iStrt:iLast),gres) ; create plot
   gsn_polyline(wks,plot,X,Y,resGs)

   draw(plot)                                      ; draw
   frame(wks)
