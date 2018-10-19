;************************************
; unique_11.ncl
;
; Concepts illustrated:
;   - Paneling 36 plots in 3 columns on a page
;   - Filling the areas of an XY curve above and below a reference line
;   - Attaching multiple XY plots along the X and Y axes
;   - Adding figure strings to paneled plots
;************************************

;***********************************************
; This NCL script pnanel plots daily index
; highted with polygon or polyline year by year.
;
; It is a typical plot that people mostly see in
; Papers climate studies
;
; NCL script contributed by Dr. Xiao-Feng Li of 
; the Institute of Atmospheric Physics (IAP),
; Chinese Acadmey of Sciences (CAS).
;************************************************

;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***********************************************
;     This function is to draw the lines       *
;***********************************************
undef("sub_draw")
function sub_draw(wks,xaxis,index,it,nyrs)
local wks,res,index,plot,xaxis,it,nyrs
begin
  res                        = True
  res@gsnFrame               = False                     ; don't draw yet
  res@gsnDraw                = False                     ; don't advance yet
  res@tfPolyDrawOrder        = "Predraw"                 ; draw the line first,
                                                         ; this is important
                                                         ; when you want to 
                                                         ; add polylines on 
                                                         ; gsn_csm_xy.
  res@tiYAxisString          = ""
  res@tiYAxisString          = ""
  res@gsnLeftString          = ""
  res@gsnRightString         = ""
  res@gsnCenterString        = ""
  res@tiMainString           = ""

  res@tiMainOn     = False
  res@tiXAxisOn    = False
  res@tiYAxisOn    = False
  res@tmXBLabelsOn = False
  res@tmYLLabelsOn = False
  res@tmYROn       = False
  res@tmYLOn       = False
  res@tmXBOn       = False
  res@tmXTOn       = False

  if( mod(it,3)  .eq. 0 ) then        ; reset the tmYLLabels of the first 
                                      ; column plots of the panel.
    res@tiYAxisOn    = True           ; In mod(it,3), 3 means the number 
                                      ; of columns in the panel.
    res@tmYLOn       = True
    res@tmYLMinorOn  = False
    res@tmYLLabelsOn = True
    ;res@tmYLFormat   =  "f"          ; trim the uneccecary "0" in labels.
    res@tmYLMode     = "Explicit"
    res@tmYLValues   = (/0.0, 1.066494*2, -1.066494*2/)  ; draw three tickmarks 
                                                         ; on the YL axais, including 
                                                         ; 0 and two criterion lines 
                                                         ; defined in the main program.
    res@tmYLLabels   = (/"0","2.13","-2.13"/)            ; Also, for a fast draw , I 
                                                         ; direct set it into number.
  end if

;---Write it into a common way, however, you can still set it by hand directly.
  if( it .eq. nyrs-1 .or. it .eq. nyrs-2 .or. it .eq. nyrs-3) then
  ;if( it .eq. 33 .or. it .eq. 34 .or. it .eq. 35) then ; to reset the tmXBLabels of
                                            ; the last raw (three plots) of the panel
    ;print("it="+it)
    res@tmXBOn       = True
    res@tmXBLabelsOn = True
    res@tmXBMode = "Explicit"
    res@tmXBValues = (/1,31,62,93,121,151/)               ; reset the tmXBLabels 
                                                          ; explicitly
    res@tmXBLabels = (/"NOV","DEC","JAN","FEB","MAR",""/)
  end if

  res@vpHeightF= 0.3               ; change aspect ratio of plot to look more beautiful
  res@vpWidthF = 0.8
  res@vpXF     = 0.1               ; Start plot at x ndc coord. Set this to save 
                                   ; more place on horizental direction. The default
                                   ; setting is 0.2.
  res@trYMinF  = -5                ; min value on y-axis
  res@trYMaxF  =  5                ; max value on y-axis

;
; Create eY reference lines.
;
; For faster drawing, gsnYRefLine is hard-coded to a value.
; This could be changed it so the value is not hard-coded.
;
  res@gsnYRefLine            = (/0.0, 1.066494*2, -1.066494*2/)
  res@gsnYRefLineDashPatterns= (/0,2,2/)

  res@gsnPaperOrientation = "portrait"
  res@xyLineColors      =  "foreground"        ; line colors
  res@xyLineThicknessF = 1.5                   ; line thicknesses
  res@xyDashPattern    = 0                     ; keep all solid

  nt              =  dimsizes(xaxis)
  res@trXMinF     =  xaxis(0)
  res@trXMaxF     =  xaxis(nt-1)

  plot = gsn_csm_xy(wks,xaxis,index,res)             ; create plot

  return(plot)
end

;***********************************************
; This function is to add polygon or polyline  *
;***********************************************
undef("sub_draw_add")
function sub_draw_add(wks,plot,xp,yp)
local wks,plot,xp,yp,dummy
begin
;
; highlight the line use gsn_add_polygon or gsn_add_polyline.
;
   gsres                   = True          ; poly res
   ;gsres@gsLineColor       = "red"        ; color chosen, setting for gsn_add_polyline
   gsres@gsFillColor       = "Salmon"      ; color chosen, setting for gsn_add_polygon
   gsres@gsLineThicknessF  = 4
   gsres@tfPolyDrawOrder        = "Postdraw"

   ;dum = gsn_add_polyline(wks,plot,xp,yp,gsres)  ; draw polyline
   dum = gsn_add_polygon(wks,plot,xp,yp,gsres)    ; draw polygon
   dname = unique_string("dum")                   ; This setting is important! If
                                                  ; you don't do this, gsn_add_polygon
                                                  ; will fail.
   plot@$dname$ = dum                             ; That way you assign a unique name
                                                  ; to each "dum" attribute, thus saving
                                                  ; each attribute and allowing each 
                                                  ; line to be drawn on each plot.
  return(plot)
end


;***********************************************
;                Main Program                  ;
;***********************************************
begin

  inf0 = "index.49-04.grd"   ; index file from 1949 to 2004, every year 151 days
  infp = "check.p.txt"           ; ascii text file containing the start and end days,
                                 ; b/w which the polyline or polygon will be added on!
  infn = "check.n.txt"           ; ascii text file containing the start and end days,
                                 ; b/w which the polyline or polygon will be added on!
  ;outname = "./index.panel.highlighted.polygon"           ; output file names
  ;outname = "./index.panel.highlighted.polyline"          ; output file names

  iyr0 = 1949                           ; start year of the index
  iyr1 = 1984                           ; end year of the index
  nyrs = iyr1-iyr0+1
  nd   = 151                            ; days of every year
  nt   = nyrs*nd                        ; total number points of the index data
  ceri = 1.066494*2.0                   ; the criterion line

;
; read in index file  from inf0
;......

  nrec  = 0
  dims  = (/nyrs,nd/)
  index = fbindirread(inf0, nrec, dims, "float")

;
; asign meta data to the index
;

  year      = ispan(iyr0,iyr1,1)
  year!0    = "year"
  year&year = year

  day       = ispan(1,nd,1)
  day!0     = "day"
  day&day   = day

  index!0    = "year"
  index&year = year
  index!1    = "day"
  index&day  = day

  printVarSummary(index)

;
; read in ascii file
;......

  datep = asciiread(infp,(/142,9/),"float") ; 142 rows X 9 colmns
  daten = asciiread(infn,(/119,9/),"float") ; 119 rows X 9 colmns

;
; draw plot
;......

   wks = gsn_open_wks("png","unique")   ; send graphics to PNG file
   xaxis = ispan(1,nd,1)  ;
   plot  = new(nyrs,graphic)

do iy=iyr0,iyr1
   it=iy-iyr0

   ; Firstly, draw the index of each year in a line figure.
   ;...

   plot(iy-iyr0)=sub_draw(wks,xaxis,index({year|iy},day|:),it,nyrs)

   ; Secondly, add the polyline or polygon in multi times.
   ; Here, I have two do loops to check out the start and end day points from
   ; two asccii text, between which the polyline or polygon will be added on! It's
   ; zero line. So, I redefine the arraies xpp and ypp, which are start and end on
   ; zero lines. This is a special case to my work with a little trouble here,
   ; because my start and end day points are not just on the zero.

   do i=0,142-1
      if( datep(i,0) .eq. iy ) then
         st = floattointeger( ceil (datep(i,4)) ) ; Computes the smallest integer 
	                                          ; value larger than the input
         ed = floattointeger( floor(datep(i,8)) ) ; Computes the largest integer 
                                                  ; value smaller than the input
         if(st .eq. 0 ) then
           st =1
         end if
         if(ed .eq. 152) then
           ed =151
         end if

         xp = ispan ( st,ed,1)*1.               ; the x cordinate of added polyline
         np = dimsizes(xp)
         yp = index({year|iy},{day|st:ed})      ; the x cordinate of added polyline

         xpp       = new(np+2,float)            ; redefine the x cordinate of added 
                                                ; polyline
         xpp(1:np) = xp(0:np-1)
         xpp(0)    = datep(i,4)
         xpp(np+1) = datep(i,8)
         ypp= new(np+2,float)                   ; redefine the x cordinate of added 
                                                ; polyline
         ypp(1:np) = yp(0:np-1)
         ypp(0) = 0
         ypp(np+1)=0

         plot(iy-iyr0)  = sub_draw_add(wks,plot(iy-iyr0),xpp,ypp)   ; draw plot, adding
                                                           ;  the polylines and polygons
         delete(xp)
         delete(yp)
         delete(np)
         delete(xpp)
         delete(ypp)
         delete(st)
         delete(ed)
       end if
   end do

   do j=0,119-1
      if( daten(j,0) .eq. iy ) then
         st = floattointeger( ceil (daten(j,4)) ) ; Computes the smallest integer value
                                                  ;  larger than the input
         ed = floattointeger( floor(daten(j,8)) ) ; Computes the largest integer value
                                                  ;  smaller than the input
         if(st .eq. 0 ) then
           st =1
         end if
         if(ed .eq. 152) then
           ed =151
         end if

         xp = ispan ( st,ed,1)*1.      ; the x cordinate of added polyline
         np = dimsizes(xp)
         yp = index({year|iy},{day|st:ed})

         xpp       = new(np+2,float)
         xpp(1:np) = xp(0:np-1)
         xpp(0)    = daten(j,4)
         xpp(np+1) = daten(j,8)
         ypp= new(np+2,float)
         ypp(1:np) = yp(0:np-1)
         ypp(0) = 0
         ypp(np+1)=0

         plot(iy-iyr0)  = sub_draw_add(wks,plot(iy-iyr0),xpp,ypp) ; draw plot, adding
                                                        ;  the polylines and polygons
         delete(xp)
         delete(yp)
         delete(np)
         delete(xpp)
         delete(ypp)
         delete(st)
         delete(ed)
       end if
   end do
end do

    resP             = True
    resP@gsnMaximize = True
    resP@gsnPaperOrientation   = "portrait"
    resP@gsnPanelFigureStrings = ispan(iyr0,iyr1,1)  ; Here is the way I draw the 1949
                                                     ; to 1984 on these plots.
    resP@gsnPanelFigureStringsFontHeightF = 0.008
    resP@amJust                = "TopRight"
    resP@amOrthogonalPosF      = -0.47
    resP@amParallelPosF        = 0.45
    resP@gsnPanelFigureStringsBackgroundFillColor   ="transparent"
    resP@gsnPanelFigureStringsPerimOn               = False
    resP@gsnPanelBottom             = 0.05
    resP@gsnPanelYWhiteSpacePercent = 0.0
    resP@gsnPanelXWhiteSpacePercent = 0.0
    resP@gsnPanelScalePlotIndex     = 1     ; This setting is important, b/c I am 
                                            ; trying to panel plots that are 
                                            ; slightly different sizes.
                                            ; So, this setting make every plot the
                                            ; same setting with plot(1) when panel 
                                            ; them up.

    gsn_panel(wks,plot,(/12,3/),resP)

   ; Convert the eps file into png if you have installed the ImageMagick
   ; in your computer!
   ;......

  ; system("convert   -trim  -page A4+0+0 "+outname+".ps "+outname+".png")
  ; system("convert   -trim  -page A4+0+0 "+outname+".ps "+outname+".png;display "+outname+".png ")


 return

end
