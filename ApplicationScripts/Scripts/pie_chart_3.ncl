;----------------------------------------------------------------------
; pie_chart_3.ncl
;
; Concepts illustrated:
;   - Drawing pie charts over a map
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually 
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"   

;----------------------------------------------------------------------
; This function adds pie charts over a map
;----------------------------------------------------------------------
undef("pie_chart_over_map")
function pie_chart_over_map(wks:graphic,plotid:graphic, xlon:numeric,ylat:numeric,percent[*]:numeric, name[*]:string        \
                              , colors[*]:string, pieChartRes:logical)
;                    Create a Pie Chart
; Nomenclature
;      percent     - percent [%: 0-100] for each section: sum(percent)=100
;                    percent = (/ 30, 10.5, 20, 39.5 /)/)
;      name        - names to be associated with each section
;                    name = (/ "Apple", "Spinach", "Orange", "Banana"/)
;      color         colors for each section
;                    color = (/ "red", "green", "blue", "brown" /)
;      pieChartRes - resources which affect plot appearance    
;                    Some examples
;                    pieChartRes = True
;                    pieChartRes@tiMainString= " ..."   [default is no title]
;                    pieChartRes@pcLabelType = "section"   [default]
;                    pieChartRes@pcLabelType = "block"  [labels beneath chart]

; pieChartRes@pcPieSize = "..."  [marker size]

 begin
  rad       = 4.*atan(1.0)/180.                ; degress to radians
  nSections = dimsizes(percent) 
  circ      = 0.1    
  if (pieChartRes .and. isatt(pieChartRes,"pcPieSizeF")) then
    circ  = pieChartRes@pcPieSizeF
  end if
                                             ; Specify limits for X and Y axes.
                 ; arbitrary

  extraSpace = 100-circ                 ; Extra space beyond outer circle
  opts       = True                     ; local and default options

  plRes                    = True       ; polyline resources
  plRes@gsLineColor        = "black"
  plRes@gsLineThicknessF   = 1.0

  gsRes                    = True       ; polymarker resources
  gsRes@gsMarkerIndex      = 16
  gsRes@gsMarkerSizeF      = 0.0115  

  txRes                    = True       ; text resources
  txRes@txJust             = "CenterLeft"
  txRes@txFontHeightF      = 0.0125            ; default=0.05
  if (pieChartRes .and. isatt(pieChartRes,"txFontHeightF")) then
      txRes@txFontHeightF = pieChartRes@txFontHeightF
  end if

  pgRes = True                                ; polygon resources
  pgRes = pieChartRes

  xOrig=0.0
  yOrig=0.0
  datatondc(plotid,xlon,ylat,xOrig,yOrig)
  xLoc   = 0.0
  yLoc   = 0.0

  pcPie  = (percent/100.)*360                  ; percent of 360 degrees 
  pcStrt = 0.0 
  pcLast = pcPie(0)
  phase  = 90.0 - 0.5*pcPie(0)                 ; 'center' 1st section n=0

  do n=0,nSections-1
                                               ; create nodes for section
     npts  = max( (/round(pcPie(n),3), 1/) )
     npts2 = npts+2
     xx    = new (npts2, "float", "No_FillValue")
     yy    = new (npts2, "float", "No_FillValue")
     xx(0) = xOrig
     yy(0) = yOrig
     if(npts.eq.1)
       pc_array := pcStrt
     else
       pc_array := fspan(pcStrt, pcLast, npts)
     end if
     xx(1:npts2-2) = xOrig+circ*cos((pc_array+phase)*rad)
     yy(1:npts2-2) = yOrig+circ*sin((pc_array+phase)*rad)
     xx(npts2-1)   = xOrig
     yy(npts2-1)   = yOrig

     pgRes@gsFillColor   =  colors(n)          ; fill with associated color
 ;    plotid@$unique_string("dum")$ = gsn_add_polygon (wks, plotid, xx, yy, pgRes)  ; color fill
 ;    plotid@$unique_string("dum")$ = gsn_add_polyline(wks, plotid, xx, yy, plRes)  ; outline

  
    if(min(xx).gt.0.and.max(xx).lt.1 )then
      if (min(yy).gt.0.and.max(yy).lt.1)then
        gsn_polygon_ndc(wks, xx, yy, pgRes);gsn_add_polygon (wks, plotid, xx, yy, pgRes)  ; color fill
;       gsn_polyline_ndc(wks,  xx, yy, plRes)  ; outline
      end if
    end if
    gsRes@gsMarkerColor = colors(n)           ; associate marker
     if (percent(n).lt.10) then
       text = sprintf("%5.1f", percent(n))+"  "+name(n)  ; include %
     else
       text = sprintf("%4.1f", percent(n))+"  "+name(n)  ; include %
    end if
                                               ; labels
    if (pieChartRes .and. \
      isatt(pieChartRes,"pcLabelType") .and. pieChartRes@pcLabelType.eq."block") then
                                               ; block labels
      if ((n%2).eq.0) then
        mx   = -circ+25.                      ; left  column labels    
      else
        mx   =  circ*0.25                     ; right column labels
      end if
   ;;datatondc(plotPC,0.0,-circ, xLoc, yLoc)
   ;;ny = yLoc - ????
      ny   = -(circ+5)
      ix   = 5   
      iy   = 6.0
      jy   = ny-(n/2)*iy
  ;   print("jy="+jy)
  ;   plotid@$unique_string("dum")$ = gsn_add_polymarker(wks, plotid,       mx   ,jy, gsRes)
  ;   plotPC@$unique_string("dum")$ = gsn_add_text      (wks, plotPC, text, mx+ix, jy, txRes)

    else    ; must be "section" labeling
                                               ; section labels
      xxInfo = (circ+0.25*extraSpace)*cos(((pcStrt+pcLast)*0.5+phase)*rad)
      yyInfo = (circ+0.25*extraSpace)*sin(((pcStrt+pcLast)*0.5+phase)*rad)
      angle  = atan2(xxInfo,yyInfo)/rad
    ;print("n="+n+"   angle="+angle+"   "+colors(n))
      ix     = 5   
      if (angle.gt.-0.001) then                 ; round
        txRes@txJust  = "CenterLeft"
   ;      plotid@$unique_string("dum")$ = gsn_add_polymarker(wks, plotid,       xxInfo   , yyInfo, gsRes)
   ;      plotid@$unique_string("dum")$ = gsn_add_text      (wks, plotid, text, xxInfo+ix, yyInfo, txRes)
      else
        txRes@txJust  = "CenterRight"
    ;     plotid@$unique_string("dum")$ = gsn_add_polymarker(wks, plotid,       xxInfo   , yyInfo, gsRes)
    ;     plotid@$unique_string("dum")$ = gsn_add_text      (wks, plotid, text, xxInfo-ix, yyInfo, txRes)
      end if
    end if

    delete(xx)
    delete(yy)

    if (n.lt.(nSections-1)) then 
      pcStrt = pcLast+0.001
      pcLast = pcLast+pcPie(n+1)
    end if
  end do

  if (.not.isatt(pieChartRes,"gsnDraw") .or. \
     (isatt(opts,"gsnDraw") .and. opts@gsnDraw)) then 
    draw(plotid)
  end if

  return (plotid)
 end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin 
  lon=(/-107.22,-104.93,-109.76,-99.25,-97.76,-94.91/)
  lat=(/61.18,60.08,58.56,57.61,56.98,57.88/)

  f1d=(/0.0023,0,0.0009,0.012,0.0092,0.00032/)
  f2d=(/0.0013,0,0.0019,0.037,0.0008,0.00023/)
  f3d=(/0.003,0.0043,0.0,0.011,0.0035,0.0012/)


  fper=new((/6,3/),float)
  fmax=new(6,float)

  fper(:,0) = (100*f1d(:)/(f1d+f2d+f3d+0.0000001))
  fper(:,1) = (100*f2d(:)/(f1d+f2d+f3d+0.0000001))
  fper(:,2) = 100-fper(:,0)-fper(:,1)

  fmax=where(f1d.gt.f2d,f1d,f2d)
  fmax=where(fmax.gt.f3d,fmax,f3d)

;------------------------------------------------------------------------
  wks = gsn_open_wks("png", "pie_chart")  ; send graphics to PNG file 

  res = True
  res@gsnDraw               = False
  res@gsnFrame              = False        

  res@gsnMaximize           = True

  res@mpLimitMode           = "Corners"
  res@mpCenterLatF          =   62
  res@mpCenterLonF          =  -80
  res@mpRightCornerLonF     =  -85
  res@mpRightCornerLatF     =   65
  res@mpLeftCornerLonF      = -107
  res@mpLeftCornerLatF      =   53

  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"
  res@mpFillOn              = False

  res@mpGridAndLimbOn       = True         ; turn on lat/lon lines
  res@mpGridSpacingF        = 10
  res@mpGridLatSpacingF     = 20

  res@mpProjection          = "Stereographic"   

  res@pmTickMarkDisplayMode = "Always"     ; turn on automatic tickmarks

  plot = gsn_csm_map(wks, res)    ;plot map


  gsres = True     ; pie chart res
  dot   = new(6,graphic)
  color = (/"red","green","blue"/)  ; colors for f1d,f2d,f3d
  name  = (/"AA","BB","CC"/)
  value = (/"0.0001","0.001","0.01"/)

  do kk=0,5
    if(fmax(kk).gt.0.0)then
      gsres@pcPieSizeF=0.0005+0.005*(5+log10(max(fmax(kk))))
      gsres@gsFillOpacityF = 0.5
      dot(kk)=pie_chart_over_map(wks,plot, lon(kk),lat(kk),fper(kk,:), name, color, gsres)
    end if
  end do

;------------------Labels--------------------

  mkres=True
  txres=True
  txres@txFontHeightF=0.02

  rad = 4.*atan(1.0)/180. 
  xx  = new(362,"float","No_FillValue")
  yy  = new(362,"float","No_FillValue")

  XOrig=(/0.2,0.5,0.8/)
  YOrig=(/0.15,0.15,0.15/)

  do ii=0,2
    circ=0.0005+0.005*(ii+1) ;size for 0.0001, 0.001, 0.01 
    xx(0)=XOrig(ii)
    yy(0)=YOrig(ii)
    xx(361)=XOrig(ii)
    yy(361)=YOrig(ii)
    xx(1:360)=xx(0)+circ*cos((fspan(0,360,360)-90.0)*rad)
    yy(1:360)=yy(0)+circ*sin((fspan(0,360,360)-90.0)*rad)

    mkres@gsFillColor    = color(ii)
    mkres@gsFillOpacityF = 0.5

    gsn_polygon_ndc(wks, xx, yy, mkres)
    gsn_text_ndc(wks, name(ii),XOrig(ii), YOrig(ii)-0.03, txres)
    gsn_text_ndc(wks, value(ii),XOrig(ii), YOrig(ii)-0.05, txres)
  end do

  draw(wks)
  frame(wks)
end
